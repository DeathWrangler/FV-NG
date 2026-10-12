package Init.PostInitActionHandlers
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureConfigManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshGifts;
   import Transactions.TTopFriends;
   import Widgets.Windows.LimitedGifting.LimitedGiftingSendToasterWindow;
   import Widgets.Windows.LimitedGifting.LimitedGiftingWindow;
   import Widgets.Windows.Market.MarketWindow;
   
   public class LimitedGiftingPostInitAction extends AbstractPostInitAction
   {
      
      private static const LIMITED_GIFTING_TYPE:String = "limitedGifting";
      
      private static const USD_GRANTED_PAIDGIFT_ONLOAD:String = "granted_paidgift_onload";
      
      private var m_features:Array = null;
      
      public function LimitedGiftingPostInitAction(callback:Function = null)
      {
         var rawXML:XML = null;
         var featuresConfig:XMLList = null;
         var featuresXML:XMLList = null;
         var i:int = 0;
         var node:XML = null;
         var hasType:Boolean = false;
         this.m_features = new Array();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HOLIDAY_PAID_GIFTING) > 0)
         {
            rawXML = Global.farmGameSettingsManager.getXML();
            featuresConfig = rawXML.featureConfig;
            if(featuresConfig != null)
            {
               featuresXML = featuresConfig.feature;
               for(i = 0; i < featuresXML.length(); i++)
               {
                  node = featuresXML[i];
                  hasType = node.hasOwnProperty("type");
                  if(node.@type != null && node.@type == LIMITED_GIFTING_TYPE)
                  {
                     if(FeatureConfigManager.featureConfigMatchesCurrentUser(node))
                     {
                        this.m_features.push(FeatureConfigManager.getFeatureConfiguration(String(node.@name)));
                     }
                  }
               }
            }
         }
         super(callback);
      }
      
      override public function execute() : void
      {
         var featureConfig:FeatureConfigManager = null;
         var featureName:String = null;
         var grantedOnload:Boolean = false;
         var friendSpec:Array = null;
         var rewardName:String = null;
         if(this.m_features.length > 0)
         {
            featureConfig = this.m_features[0] as FeatureConfigManager;
            featureName = featureConfig.featureName;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIMITED_GIFTING) > 1)
            {
               friendSpec = [["CurrentMostGifts","CurrentMostHelpful","CurrentFriendsAlpha"]];
               TransactionManager.addTransaction(new TGenericTransaction("FriendListService","getFriendsForPaidGifting",this.handleFriendListServiceCallback,friendSpec as Array),true);
            }
            else
            {
               TransactionManager.addTransaction(new TTopFriends(this.initializeHUD,featureName),true);
            }
            grantedOnload = FeatureOptionsManager.getInstance().getFeatureOption(featureName,USD_GRANTED_PAIDGIFT_ONLOAD) as Boolean;
            if(grantedOnload == true)
            {
               TransactionManager.addTransaction(new TRefreshGifts(),false);
               rewardName = featureConfig.getStringConstant("appreciationItem");
               if(rewardName != null)
               {
                  ToasterManager.getInstance().add(new LimitedGiftingSendToasterWindow(rewardName,featureName));
                  FeatureOptionsManager.getInstance().setFeatureOption(featureName,USD_GRANTED_PAIDGIFT_ONLOAD,false);
                  FeatureOptionsManager.getInstance().save();
               }
            }
         }
         m_isFinished = true;
      }
      
      private function handleFriendListServiceCallback(result:Object) : void
      {
         this.initializeHUD(result,"giftingUIUrlMFS");
      }
      
      private function initializeHUD(result:Object, dialogUrlKey:String = "giftingUIUrl") : void
      {
         var feature:FeatureConfigManager = null;
         var extraData:Object = null;
         var hudURL:String = null;
         var featureName:String = null;
         var iconTooltip:String = null;
         var lastShown:Number = NaN;
         var dialog:LimitedGiftingWindow = null;
         if(result.length > 0 || result.hasOwnProperty("requestedFriends"))
         {
            for each(feature in this.m_features)
            {
               extraData = new Object();
               hudURL = feature.getStringConstant("hudIconUrl");
               featureName = feature.featureName;
               iconTooltip = ZLocUtils.t("Dialogs",featureName + "_iconTooltip");
               if(iconTooltip != null && iconTooltip != "")
               {
                  extraData["iconTooltip"] = iconTooltip;
               }
               extraData["giftingUIUrl"] = feature.getStringConstant(dialogUrlKey);
               extraData["giftingUIUrlChoice"] = feature.getStringConstant("giftingUIUrlChoice");
               extraData["featureName"] = featureName;
               extraData["friendsList"] = result;
               extraData["mainWindowBackgroundImage"] = feature.getStringConstant("mainWindowBackgroundImage");
               Global.hud.rightSideIconQueue.addIcon("limitedGifting",DynamicIconQueue.ADD_BY_PRIORITY,hudURL,extraData,false);
               MarketWindow.openLimitedGiftingWindowOnMarketAddClicked();
               if(feature.getNumberConstant("autoShowInterval") != 0)
               {
                  lastShown = Global.player.getFeatureLastShown(featureName);
                  if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShown > feature.getNumberConstant("autoShowInterval"))
                  {
                     dialog = new LimitedGiftingWindow(extraData);
                     UI.displayPopup(dialog,false,featureName,true);
                     Global.player.setFeatureLastShown(featureName,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                  }
               }
            }
         }
      }
   }
}

