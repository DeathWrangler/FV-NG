package Widgets.Frames.SlotMachine
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class SlotMachineFullBonusFrame extends ZwFrame
   {
      
      private var m_building:FeatureBuilding;
      
      private var m_freeThrowsTextField:ZwTextField;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_icon:FarmIcon;
      
      public function SlotMachineFullBonusFrame(element:DisplayObject, building:FeatureBuilding)
      {
         super(element);
         this.m_building = building;
         this.m_freeThrowsTextField = addWidget(new ZwTextField(m_element.generic_tf)) as ZwTextField;
         this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element.share_bt,"Share",this.m_building.slotmachine.onShareBonus)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.update();
      }
      
      public function update() : void
      {
         var item:FarmItem = null;
         var buildingData:Object = this.m_building.slotmachine.lastTransactionResult;
         if(Boolean(buildingData) && Boolean(buildingData.hasOwnProperty("lootItemName")) && Boolean(buildingData.lootItemName))
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(buildingData.lootItemName);
            }
            else
            {
               item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(buildingData.lootItemName));
            }
            this.m_freeThrowsTextField.text = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            this.m_icon.loadIcon(item.iconUrl);
         }
      }
   }
}

