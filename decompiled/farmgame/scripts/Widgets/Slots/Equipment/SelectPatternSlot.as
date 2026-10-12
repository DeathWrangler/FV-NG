package Widgets.Slots.Equipment
{
   import Classes.Equipment;
   import Managers.EquipmentSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Equipment.SelectPatternWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class SelectPatternSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_data:Object;
      
      private var m_selected:Boolean;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_backgroundOnWidget:ZwWidget;
      
      private var m_backgroundOffWidget:ZwWidget;
      
      private var m_selectButton:FarmAnimatedTextButton;
      
      public function SelectPatternSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.copy_tf,"")) as ZwTextField;
         this.m_backgroundOnWidget = addWidget(new ZwWidget(m_element.bgOn_mc)) as ZwWidget;
         this.m_backgroundOffWidget = addWidget(new ZwWidget(m_element.bgOff_mc)) as ZwWidget;
         this.m_selectButton = addWidget(new FarmAnimatedTextButton(m_element.harvest_bt,"Select",this.onSelectButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_backgroundOnWidget = null;
         this.m_backgroundOffWidget = null;
         this.m_selectButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var parentWindow:SelectPatternWindow = null;
         var equipment:Equipment = null;
         var patternOption:String = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_icon.loadIcon(Global.getAssetURL(this.m_data.iconUrl));
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_data.actionSizeX + "x" + this.m_data.actionSizeY;
            this.m_nameTextField.visible = true;
            this.m_selectButton.visible = true;
            parentWindow = getAncestorByClassType(SelectPatternWindow) as SelectPatternWindow;
            equipment = parentWindow.equipment;
            patternOption = EquipmentSettingsManager.getInstance().getPatternOption(equipment.getItem().code);
            this.m_selected = this.m_data.name == patternOption;
            this.m_backgroundOnWidget.visible = this.m_selected;
            this.m_backgroundOffWidget.visible = !this.m_selected;
         }
      }
      
      private function onSelectButtonClick(event:MouseEvent) : void
      {
         var parentWindow:SelectPatternWindow = getAncestorByClassType(SelectPatternWindow) as SelectPatternWindow;
         var equipment:Equipment = parentWindow.equipment;
         EquipmentSettingsManager.getInstance().setPatternOption(this.m_data.name,equipment.getItem().code);
         var actionSize:String = this.m_data.actionSizeX + "x" + this.m_data.actionSizeY;
         FarmStatsManager.count("select_pattern",equipment.getItemName(),actionSize);
         equipment.performEquipmentAction(parentWindow.source);
         parentWindow.close();
      }
   }
}

