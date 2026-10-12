package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class ItemMembershipLevelUpWindow extends FarmWindowWithBackground
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_SubscriptionsClub_prize.swf";
      
      private static const UI_DUP_KEY:String = "Widgets.Windows.ItemMembershipLevelUpWindow";
      
      private static const STATS_KEY_LEVEL_UP_DIALOG:String = "level_up_dialog";
      
      private var m_featureName:String;
      
      private var m_bonusItemNames:Array;
      
      public function ItemMembershipLevelUpWindow(featureName:String, bonusItemNames:Array)
      {
         this.m_featureName = featureName;
         this.m_bonusItemNames = bonusItemNames;
         super(ASSET_PATH,ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_WELCOME_WINDOW_BACKGROUND_IMAGE));
      }
      
      public static function showStatic(featureName:String, bonusItemNames:Array) : void
      {
         UI.displayPopup(new ItemMembershipLevelUpWindow(featureName,bonusItemNames),true,UI_DUP_KEY,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var zLocObj:Object = null;
         var item:FarmItem = null;
         var numBonusItemNames:int = 0;
         var zLocKey:String = null;
         var i:int = 0;
         var ZLocObj:Object = null;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window["generic_tf"])
            {
               addWidget(new ZwTextField(m_window.generic_tf,ItemMembershipManager.FEATURE_TYPE + "_congrats",false,"Dialogs"),true);
            }
            if(m_window["generic2_tf"])
            {
               zLocObj = {"itemNameSingular":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR)};
               zLocKey = ItemMembershipManager.FEATURE_TYPE + "_level_up_copy_1";
               addWidget(new ZwTextField(m_window.generic2_tf,zLocKey,false,"Dialogs",zLocObj),true);
            }
            if(m_window["generic3_tf"])
            {
               zLocObj = {
                  "numCreditsPerMonth":ItemMembershipManager.getConstantsIntWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_NUM_CREDITS_PER_MONTH),
                  "creditName":ZLocUtils.t("Dialogs",this.m_featureName + "_credits_name")
               };
               addWidget(new ZwTextField(m_window.generic3_tf,ItemMembershipManager.FEATURE_TYPE + "_level_up_copy_2",false,"Dialogs",zLocObj),true);
            }
            if(m_window["share_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_redeem"),this.onRedeemButtonClicked),true);
            }
            if(Boolean(this.m_bonusItemNames) && this.m_bonusItemNames.length > 0)
            {
               numBonusItemNames = int(this.m_bonusItemNames.length);
               if(Boolean(numBonusItemNames == 1) && Boolean(m_window["icon0_mc"]) && Boolean(m_window["icon1_mc"]))
               {
                  m_window.icon0_mc.x = (m_window.icon0_mc.x + m_window.icon1_mc.x) / 2;
               }
               for(i = 0; i < numBonusItemNames; i++)
               {
                  if(m_window["icon" + i + "_mc"])
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusItemNames[i]);
                     if(item)
                     {
                        addWidget(new FarmIcon(m_window["icon" + i + "_mc"],item.getImageByName("feed",false)),true);
                     }
                  }
               }
            }
            if(m_window["generic4_tf"])
            {
               if(numBonusItemNames > 1)
               {
                  ZLocObj = {"pronoun":"them"};
               }
               else
               {
                  ZLocObj = {"pronoun":"it"};
               }
               addWidget(new ZwTextField(m_window.generic4_tf,ItemMembershipManager.FEATURE_TYPE + "_level_up_copy_3",false,"Dialogs",ZLocObj),true);
            }
            this.count(StatsTrackingConstants.IMPRESSIONS,ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.NUM_MONTHS_SUBSCRIBED));
         }
      }
      
      private function onRedeemButtonClicked(event:Event) : void
      {
         this.count(StatsTrackingConstants.CLICK_REDEEM);
         ItemMembershipWindow.showStatic(this.m_featureName);
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.count(StatsTrackingConstants.CLOSE);
         super.onClose(event);
      }
      
      private function count(phylum:String, statClass:String = "") : void
      {
         StatsManager.count(this.m_featureName,STATS_KEY_LEVEL_UP_DIALOG,phylum,statClass);
      }
   }
}

