// Import all controller files
import AccordionController from "./accordion/accordion_controller";
import AlertDialogController from "./alert_dialog/alert_dialog_controller";
import CalendarController from "./calendar/calendar_controller";
import CalendarInputController from "./calendar/calendar_input_controller";
import CollapsibleController from "./collapsible/collapsible_controller";
import ChartController from "./chart/chart_controller";
import CheckboxGroupController from "./checkbox/checkbox_group_controller";
import ClipboardController from "./clipboard/clipboard_controller";
import ComboboxController from "./combobox/combobox_controller";
import ComboboxContentController from "./combobox/combobox_content_controller";
import ComboboxItemController from "./combobox/combobox_item_controller";
import CommandController from "./command/command_controller";
import ContextMenuController from "./context_menu/context_menu_controller";
import DialogController from "./dialog/dialog_controller";
import DropdownMenuController from "./dropdown_menu/dropdown_menu_controller";
import FormFieldController from "./form/form_field_controller";
import HoverCardController from "./hover_card/hover_card_controller";
import PopoverController from "./popover/popover_controller";
import TabsController from "./tabs/tabs_controller";
import ThemeToggleController from "./theme_toggle/theme_toggle_controller";
import TooltipController from "./tooltip/tooltip_controller";
import SelectController from "./select/select_controller";
import SelectItemController from "./select/select_item_controller";
import SheetController from "./sheet/sheet_controller";
import SheetContentController from "./sheet/sheet_content_controller";

function initialize(application) {
  const registerIfNotExists = (identifier, controller) => {
    if (!application.router.modulesByIdentifier.has(identifier)) {
      application.register(identifier, controller);
      // console.log(`Registered: ${identifier}`);
    }
  };

  // Register all controllers
  registerIfNotExists("ruby_ui--accordion", AccordionController);
  registerIfNotExists("ruby_ui--alert-dialog", AlertDialogController);
  registerIfNotExists("ruby_ui--calendar", CalendarController);
  registerIfNotExists("ruby_ui--calendar-input", CalendarInputController);
  registerIfNotExists("ruby_ui--collapsible", CollapsibleController);
  registerIfNotExists("ruby_ui--chart", ChartController);
  registerIfNotExists("ruby_ui--checkbox-group", CheckboxGroupController);
  registerIfNotExists("ruby_ui--clipboard", ClipboardController);
  registerIfNotExists("ruby_ui--combobox", ComboboxController);
  registerIfNotExists("ruby_ui--combobox-content", ComboboxContentController);
  registerIfNotExists("ruby_ui--combobox-item", ComboboxItemController);
  registerIfNotExists("ruby_ui--command", CommandController);
  registerIfNotExists("ruby_ui--context-menu", ContextMenuController);
  registerIfNotExists("ruby_ui--dialog", DialogController);
  registerIfNotExists("ruby_ui--dropdown-menu", DropdownMenuController);
  registerIfNotExists("ruby_ui--form-field", FormFieldController);
  registerIfNotExists("ruby_ui--hover-card", HoverCardController);
  registerIfNotExists("ruby_ui--popover", PopoverController);
  registerIfNotExists("ruby_ui--tabs", TabsController);
  registerIfNotExists("ruby_ui--theme-toggle", ThemeToggleController);
  registerIfNotExists("ruby_ui--tooltip", TooltipController);
  registerIfNotExists("ruby_ui--select", SelectController);
  registerIfNotExists("ruby_ui--select-item", SelectItemController);
  registerIfNotExists("ruby_ui--sheet", SheetController);
  registerIfNotExists("ruby_ui--sheet-content", SheetContentController);
}

const RubyUI = {
  initialize,
};

export default RubyUI;

export { initialize };
