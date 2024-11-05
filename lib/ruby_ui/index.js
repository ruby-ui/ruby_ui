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
  registerIfNotExists("rbui--accordion", AccordionController);
  registerIfNotExists("rbui--alert-dialog", AlertDialogController);
  registerIfNotExists("rbui--calendar", CalendarController);
  registerIfNotExists("rbui--calendar-input", CalendarInputController);
  registerIfNotExists("rbui--collapsible", CollapsibleController);
  registerIfNotExists("rbui--chart", ChartController);
  registerIfNotExists("rbui--checkbox-group", CheckboxGroupController);
  registerIfNotExists("rbui--clipboard", ClipboardController);
  registerIfNotExists("rbui--combobox", ComboboxController);
  registerIfNotExists("rbui--combobox-content", ComboboxContentController);
  registerIfNotExists("rbui--combobox-item", ComboboxItemController);
  registerIfNotExists("rbui--command", CommandController);
  registerIfNotExists("rbui--context-menu", ContextMenuController);
  registerIfNotExists("rbui--dialog", DialogController);
  registerIfNotExists("rbui--dropdown-menu", DropdownMenuController);
  registerIfNotExists("rbui--form-field", FormFieldController);
  registerIfNotExists("rbui--hover-card", HoverCardController);
  registerIfNotExists("rbui--popover", PopoverController);
  registerIfNotExists("rbui--tabs", TabsController);
  registerIfNotExists("rbui--theme-toggle", ThemeToggleController);
  registerIfNotExists("rbui--tooltip", TooltipController);
  registerIfNotExists("rbui--select", SelectController);
  registerIfNotExists("rbui--select-item", SelectItemController);
  registerIfNotExists("rbui--sheet", SheetController);
  registerIfNotExists("rbui--sheet-content", SheetContentController);
}

const RubyUI = {
  initialize,
};

export default RubyUI;

export { initialize };
