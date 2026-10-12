package Widgets.Windows.Equipment
{
   import Classes.Equipment;
   import Classes.util.ZLocUtils;
   import Managers.EquipmentSettingsManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Equipment.SelectPatternSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   
   public class SelectPatternWindow extends FarmWindow
   {
      
      private var m_equipment:Equipment;
      
      private var m_source:String;
      
      private var m_slots:SelectPatternSlotContainerFrame;
      
      public function SelectPatternWindow(equipment:Equipment, source:String = null, assetPath:String = null)
      {
         this.m_equipment = equipment;
         this.m_source = source;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var selectedPattern:Object = null;
         var pattern:Object = null;
         var fuelWidget:ZwFrame = null;
         addWidget(new ZwTextField(m_window.title_tf,this.m_equipment.getItem().friendlyTitle));
         var infoKey:String = "SelectPatternWindow_Info_" + this.m_equipment.getItemName();
         if(ZLocUtils.hasString("Dialogs",infoKey))
         {
            addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t("Dialogs",infoKey)));
         }
         var fuelKey:String = "SelectPatternWindow_Fuel_" + this.m_equipment.getItemName();
         if(ZLocUtils.hasString("Dialogs",fuelKey))
         {
            fuelWidget = addWidget(new ZwFrame(m_window.fuel_mc)) as ZwFrame;
            fuelWidget.addWidget(new ZwTextField(m_window.fuel_mc.fuel_tf,ZLocUtils.t("Dialogs",fuelKey,{"energyCost":String(this.m_equipment.getEnergyCost())})));
         }
         var patternOption:String = EquipmentSettingsManager.getInstance().getPatternOption(this.equipment.getItem().code);
         var sortedPatterns:Array = [];
         var availablePatterns:Array = EquipmentSettingsManager.getInstance().getPatterns(this.m_equipment.equipmentPartsCount,this.m_equipment.getItem().code);
         for each(pattern in availablePatterns)
         {
            if(pattern.name == patternOption)
            {
               selectedPattern = pattern;
            }
            else
            {
               sortedPatterns.push(pattern);
            }
         }
         sortedPatterns.unshift(selectedPattern);
         this.m_slots = addWidget(new SelectPatternSlotContainerFrame(m_window.slots_mc)) as SelectPatternSlotContainerFrame;
         this.m_slots.items = sortedPatterns;
         if(m_window.hasOwnProperty("preview_mc"))
         {
            addWidget(new ObjectPreviewFrame(m_window.preview_mc,this.m_equipment.getItem()));
         }
      }
      
      override protected function release() : void
      {
         this.m_equipment = null;
         this.m_slots = null;
         super.release();
      }
      
      public function get equipment() : Equipment
      {
         return this.m_equipment;
      }
      
      public function get source() : String
      {
         return this.m_source;
      }
   }
}

