# frozen_string_literal: true

require "test_helper"

class RubyUI::SidebarTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Sidebar.new.is_a?(Phlex::HTML)
  end

  def test_collapsible_by_default
    sb = RubyUI::Sidebar.new
    assert sb.collapsible?
  end

  def test_none_collapsible
    sb = RubyUI::Sidebar.new(collapsible: :none)
    refute sb.collapsible?
  end

  def test_default_side_left
    sb = RubyUI::Sidebar.new
    assert_equal :left, sb.side
  end

  def test_side_right
    sb = RubyUI::Sidebar.new(side: :right)
    assert_equal :right, sb.side
  end

  def test_invalid_side_raises
    assert_raises(ArgumentError) { RubyUI::Sidebar.new(side: :top) }
  end

  def test_invalid_collapsible_raises
    assert_raises(ArgumentError) { RubyUI::Sidebar.new(collapsible: :invalid) }
  end

  def test_open_by_default
    sb = RubyUI::Sidebar.new
    assert sb.open?
  end

  def test_closed
    sb = RubyUI::Sidebar.new(open: false)
    refute sb.open?
  end

  def test_collapsible_sidebar_data_expanded
    cs = RubyUI::CollapsibleSidebar.new
    assert_equal "expanded", cs.sidebar_data[:state]
    assert_equal "sidebar", cs.sidebar_data[:ruby_ui__sidebar_target]
  end

  def test_collapsible_sidebar_data_collapsed
    cs = RubyUI::CollapsibleSidebar.new(open: false, collapsible: :offcanvas)
    assert_equal "collapsed", cs.sidebar_data[:state]
    assert_equal :offcanvas, cs.sidebar_data[:collapsible]
  end

  def test_collapsible_sidebar_side_right
    cs = RubyUI::CollapsibleSidebar.new(side: :right)
    assert_includes cs.content_wrapper_class, "right-0"
    refute_includes cs.content_wrapper_class, "left-0"
  end

  def test_collapsible_sidebar_side_left
    cs = RubyUI::CollapsibleSidebar.new(side: :left)
    assert_includes cs.content_wrapper_class, "left-0"
  end

  def test_non_collapsible_sidebar_class
    nc = RubyUI::NonCollapsibleSidebar.new
    assert_includes nc.attrs[:class], "bg-sidebar"
    assert_includes nc.attrs[:class], "text-sidebar-foreground"
  end

  def test_mobile_sidebar_target
    ms = RubyUI::MobileSidebar.new
    assert_equal "mobileSidebar", ms.attrs.dig(:data, :ruby_ui__sidebar_target)
  end

  def test_sidebar_wrapper_has_controller
    sw = RubyUI::SidebarWrapper.new
    assert_equal "ruby-ui--sidebar", sw.attrs.dig(:data, :controller)
  end

  def test_sidebar_wrapper_has_css_vars
    sw = RubyUI::SidebarWrapper.new
    assert_includes sw.attrs[:style], "--sidebar-width"
  end

  def test_sidebar_content_data
    sc = RubyUI::SidebarContent.new
    assert_equal "content", sc.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_header_data
    sh = RubyUI::SidebarHeader.new
    assert_equal "header", sh.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_footer_data
    sf = RubyUI::SidebarFooter.new
    assert_equal "footer", sf.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_group_data
    sg = RubyUI::SidebarGroup.new
    assert_equal "group", sg.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_group_label_data
    sgl = RubyUI::SidebarGroupLabel.new
    assert_equal "group-label", sgl.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_group_action_default_tag
    sga = RubyUI::SidebarGroupAction.new
    assert_equal :button, sga.tag_name
  end

  def test_sidebar_group_content_data
    sgc = RubyUI::SidebarGroupContent.new
    assert_equal "group-content", sgc.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_inset_class
    si = RubyUI::SidebarInset.new
    assert_includes si.attrs[:class], "bg-background"
  end

  def test_sidebar_input_data
    si = RubyUI::SidebarInput.new
    assert_equal "input", si.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_separator_data
    ss = RubyUI::SidebarSeparator.new
    assert_equal "separator", ss.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_data
    sm = RubyUI::SidebarMenu.new
    assert_equal "menu", sm.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_item_data
    smi = RubyUI::SidebarMenuItem.new
    assert_equal "menu-item", smi.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_button_data
    smb = RubyUI::SidebarMenuButton.new
    assert_equal "menu-button", smb.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_button_invalid_variant_raises
    assert_raises(ArgumentError) { RubyUI::SidebarMenuButton.new(variant: :invalid) }
  end

  def test_sidebar_menu_action_data
    sma = RubyUI::SidebarMenuAction.new
    assert_equal "menu-action", sma.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_badge_data
    smb = RubyUI::SidebarMenuBadge.new
    assert_equal "menu-badge", smb.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_skeleton_data
    sms = RubyUI::SidebarMenuSkeleton.new
    assert_equal "menu-skeleton", sms.attrs.dig(:data, :sidebar)
    refute sms.show_icon?
  end

  def test_sidebar_menu_skeleton_show_icon
    sms = RubyUI::SidebarMenuSkeleton.new(show_icon: true)
    assert sms.show_icon?
  end

  def test_sidebar_menu_sub_data
    sms = RubyUI::SidebarMenuSub.new
    assert_equal "menu-sub", sms.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_menu_sub_button_size_classes
    smsb = RubyUI::SidebarMenuSubButton.new(size: :sm)
    assert_includes smsb.attrs[:class], "text-xs"
  end

  def test_sidebar_menu_sub_button_invalid_size_raises
    assert_raises(ArgumentError) { RubyUI::SidebarMenuSubButton.new(size: :xl) }
  end

  def test_sidebar_rail_data
    sr = RubyUI::SidebarRail.new
    assert_equal "rail", sr.attrs.dig(:data, :sidebar)
  end

  def test_sidebar_trigger_data
    st = RubyUI::SidebarTrigger.new
    assert_equal "trigger", st.attrs.dig(:data, :sidebar)
    assert_includes st.attrs[:class], "h-7"
  end
end
