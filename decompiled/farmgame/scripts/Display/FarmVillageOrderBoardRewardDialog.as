package Display
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   
   public class FarmVillageOrderBoardRewardDialog extends LevelUpWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/Village/FV_xfv_reward.swf";
      
      private static const LEVEL_MC:String = "level_mc";
      
      private static const UNLOCKED_MC:String = "unlocked_mc";
      
      private static const SLOT_ONE_MC:String = "slot1_mc";
      
      private static const ICON_MC:String = "icon_mc";
      
      private var m_itemName:String;
      
      private var m_currency:int;
      
      private var m_experience:int;
      
      public function FarmVillageOrderBoardRewardDialog(itemName:String, currency:int, experience:int)
      {
         super(DIALOG_ASSET,0);
         this.m_itemName = itemName;
         this.m_experience = experience;
         this.m_currency = currency;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var farmItem:FarmItem = null;
         var unlockedFrame:ZwFrame = null;
         var iconSlotFrame:ZwFrame = null;
         super.onLoadComplete(event);
         if(m_window)
         {
            (getWidget(m_window["ok_bt"]) as FarmAnimatedTextButton).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"OkButton");
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            unlockedFrame = null;
            if(Boolean(m_window[LEVEL_MC]) && Boolean(m_window[LEVEL_MC]["generic_tf"]))
            {
               m_window.level_mc.generic_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageRewardDialogTitle");
            }
            if(m_window[UNLOCKED_MC])
            {
               unlockedFrame = new ZwFrame(m_window.unlocked_mc);
               addWidget(unlockedFrame);
               if(m_window[UNLOCKED_MC]["header_tf"])
               {
                  unlockedFrame.addWidget(new FarmTextField(m_window.unlocked_mc.header_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageRewardDialogHeader",{"item":ZLocUtils.tk_pk(farmItem.friendlyName)})));
               }
               if(m_window[UNLOCKED_MC]["subheader_tf"])
               {
                  unlockedFrame.addWidget(new FarmTextField(m_window.unlocked_mc.subheader_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageRewardDialogSubHeader",{
                     "currencyQuantity":this.m_currency,
                     "experienceQuantity":this.m_experience,
                     "currency":ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"menu_villageCurrency"),
                     "experience":ZLocUtils.t("FarmGame",FarmVillageManager.WORLD_SCORE_NAME)
                  })));
               }
               iconSlotFrame = null;
               if(Boolean(m_window[UNLOCKED_MC][SLOT_ONE_MC]) && Boolean(m_window[UNLOCKED_MC][SLOT_ONE_MC][ICON_MC]))
               {
                  iconSlotFrame = new ZwFrame(m_window.unlocked_mc[SLOT_ONE_MC]);
                  unlockedFrame.addWidget(iconSlotFrame);
                  if(farmItem)
                  {
                     iconSlotFrame.addWidget(new FarmIcon(m_window.unlocked_mc[SLOT_ONE_MC][ICON_MC],farmItem.icon));
                     iconSlotFrame.attachTooltip(new FarmTextTooltip(farmItem.friendlyTitle));
                  }
               }
            }
         }
      }
   }
}

