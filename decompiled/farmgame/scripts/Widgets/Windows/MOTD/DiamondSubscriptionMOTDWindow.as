package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.SubscriptionsItemDropManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   
   public class DiamondSubscriptionMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private const ICON_MC:String = "icon_mc";
      
      private const SLOT_1_TF:String = "unicornTitle_tf";
      
      private const SLOT_2_TF:String = "fcTitle_tf";
      
      private const SLOT_3_TF:String = "superTitle_tf";
      
      private const TEXT_PREFIX:String = "DiamondSubscriptionMOTD";
      
      private var m_iconMC:FarmIcon;
      
      private var m_slot1TF:ZwTextField;
      
      private var m_slot2TF:ZwTextField;
      
      private var m_slot3TF:ZwTextField;
      
      public function DiamondSubscriptionMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var unicornManager:SubscriptionsItemDropManager = null;
         var unicornName:String = null;
         var unicornItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.mainWindow.hasOwnProperty([this.ICON_MC]))
         {
            unicornManager = SubscriptionsItemDropManager.getInstance();
            unicornName = unicornManager.getCurrentDropItemName();
            if(unicornName)
            {
               unicornItem = Global.farmGameSettingsManager.getFarmItemByName(unicornName);
               if(unicornItem)
               {
                  this.m_iconMC = addWidget(new FarmIcon(m_window.mainWindow[this.ICON_MC],unicornItem.getImageByName("feed"))) as FarmIcon;
               }
            }
         }
         if(m_window.mainWindow.hasOwnProperty([this.SLOT_1_TF]))
         {
            this.m_slot1TF = addWidget(new ZwTextField(m_window.mainWindow[this.SLOT_1_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PREFIX + "_SlotText1"))) as ZwTextField;
         }
         if(m_window.mainWindow.hasOwnProperty([this.SLOT_2_TF]))
         {
            this.m_slot2TF = addWidget(new ZwTextField(m_window.mainWindow[this.SLOT_2_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PREFIX + "_SlotText2"))) as ZwTextField;
         }
         if(m_window.mainWindow.hasOwnProperty([this.SLOT_3_TF]))
         {
            this.m_slot3TF = addWidget(new ZwTextField(m_window.mainWindow[this.SLOT_3_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PREFIX + "_SlotText3"))) as ZwTextField;
         }
      }
   }
}

