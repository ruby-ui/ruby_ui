import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

// Function to get theme color
const getThemeColor = (name) => {
  const color = getComputedStyle(document.documentElement).getPropertyValue(`--${name}`)
  const [ hue, saturation, lightness ] = color.split(' ')
  return `hsl(${hue}, ${saturation}, ${lightness})`
}

// Function to set default properties for the chart
const setDefaults = (propertyPath, value) => {
  let currentProperty = Chart.defaults;
  for (let index = 0; index < propertyPath.length; index++) {
    const property = propertyPath[index];
    if (index === propertyPath.length - 1) {
      currentProperty[property] = value;
    } else {
      currentProperty = currentProperty[property];
    }
  }
}

// Chart controller
export default class extends Controller {
  static values = {
    options: {
      type: Object,
      default: {},
    },
  }

  // Function to initialize the chart when the controller is connected
  connect() {
    this.setThemeDefaults()
    this.initDarkModeObserver()
    this.initChart()
  }

  // Function to clean up when the controller is disconnected
  disconnect() {
    this.observer.disconnect()
    this.chart.destroy()
  }

  // Function to initialize the chart
  initChart() {
    const editedDatasets = this.setDatasetColors(this.optionsValue.data.datasets)

    // Set the colors for the chart
    this.optionsValue = {
      ...this.optionsValue,
      data: {
        ...this.optionsValue.data,
        datasets: editedDatasets,
      },
    };

    console.log(this.optionsValue); // Log the options

    this.chart = new Chart(this.element, this.optionsValue)
  }

  // Function to refresh the chart
  refresh() {
    this.chart.destroy()
    this.setThemeDefaults()
    this.initChart()
  }

  // Function to set theme colors for the chart
  setThemeDefaults() {
    setDefaults(['color'], getThemeColor('muted-foreground'));
    setDefaults(['borderColor'], getThemeColor('border'));

    // tooltip
    setDefaults(['plugins', 'tooltip', 'backgroundColor'], getThemeColor('background'));
    setDefaults(['plugins', 'tooltip', 'borderColor'], getThemeColor('border'));
    setDefaults(['plugins', 'tooltip', 'borderWidth'], 1);
    setDefaults(['plugins', 'tooltip', 'titleColor'], getThemeColor('foreground'));
    setDefaults(['plugins', 'tooltip', 'bodyColor'], getThemeColor('muted-foreground'));
    setDefaults(['plugins', 'tooltip', 'titleFont', 'family'], 'inherit');

    // legend
    setDefaults(['plugins', 'legend', 'labels', 'color'], getThemeColor('foreground'));
    
    // line chart
    Chart.defaults.elements.line.tension = 0.5;
  }

  // Function to set dataset colors
  setDatasetColors(datasets = []) {
    const color = getThemeColor('primary');

    return datasets.map(dataset => {
      let updatedDataset = {
        ...dataset,
        borderColor: color,
        backgroundColor: color,
        strokeColor: color,
      };

      if (updatedDataset.data && Array.isArray(updatedDataset.data)) {
        updatedDataset.data = updatedDataset.data.map(dataPoint => (
          typeof dataPoint === 'object'
            ? { ...dataPoint, borderColor: color, backgroundColor: color, strokeColor: color }
            : dataPoint
        ));
      }

      return updatedDataset;
    });
  }

  // Function to initialize dark mode observer
  initDarkModeObserver() {
    this.observer = new MutationObserver((mutationsList, observer) => {
      for(let mutation of mutationsList) {
        if(mutation.type === 'attributes' && mutation.attributeName === 'class') {
          this.refresh();
        }
      }
    });
    this.observer.observe(document.documentElement, { attributes: true });
  }
}