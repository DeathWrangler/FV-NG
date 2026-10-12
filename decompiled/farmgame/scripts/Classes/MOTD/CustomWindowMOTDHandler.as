package Classes.MOTD
{
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Widgets.Windows.MOTD.AFInnovationMOTDWindow;
   import Widgets.Windows.MOTD.AFInnovationMarketingMOTDWindow;
   import Widgets.Windows.MOTD.AmexMOTDV2Window;
   import Widgets.Windows.MOTD.AmexTreeMOTDWindow;
   import Widgets.Windows.MOTD.AnimalSanctuaryMOTD;
   import Widgets.Windows.MOTD.AnimalSanctuaryV2MOTD;
   import Widgets.Windows.MOTD.AntiqueMuseumMOTDWindow;
   import Widgets.Windows.MOTD.AntiqueMuseumV2MOTD;
   import Widgets.Windows.MOTD.BoatRushMOTD;
   import Widgets.Windows.MOTD.BobBerryWidgetMOTDWindow;
   import Widgets.Windows.MOTD.BoraboraInnovationMOTD;
   import Widgets.Windows.MOTD.BoraboraInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.BrInnovationPremarketingMOTDWindow;
   import Widgets.Windows.MOTD.BuyFromFeedsOfferWindow;
   import Widgets.Windows.MOTD.CPAFlowerOfferMOTDWindow;
   import Widgets.Windows.MOTD.CategorySpecificSaleMOTDWindow;
   import Widgets.Windows.MOTD.CheckRequireOnShowMOTDWindow;
   import Widgets.Windows.MOTD.ChristmasCharityBundleMOTD;
   import Widgets.Windows.MOTD.ClickToAnimateSingleButtonMOTD;
   import Widgets.Windows.MOTD.CocowonderlandInnovationMOTDWindow;
   import Widgets.Windows.MOTD.CommunityGoalsMOTDWindow;
   import Widgets.Windows.MOTD.CommunityV2MOTDWindow;
   import Widgets.Windows.MOTD.CustomMarketMOTDWindow;
   import Widgets.Windows.MOTD.CustomWindowMOTDBase;
   import Widgets.Windows.MOTD.DiamondSubscriptionMOTDWindow;
   import Widgets.Windows.MOTD.DragonBreedingEventMOTDWindow;
   import Widgets.Windows.MOTD.DragonBreedingMOTDWindow;
   import Widgets.Windows.MOTD.DreamFishDesignerWidgetMOTDWindow;
   import Widgets.Windows.MOTD.EdibleSchoolyardMOTDWindow;
   import Widgets.Windows.MOTD.ExperimentGatedTrailerMOTD;
   import Widgets.Windows.MOTD.FBPermissionRequestMOTDWindow;
   import Widgets.Windows.MOTD.FVSunsetMOTD;
   import Widgets.Windows.MOTD.FVTECurrencyMOTD;
   import Widgets.Windows.MOTD.FarmExpressMOTDWindow;
   import Widgets.Windows.MOTD.FarmRun2018PremarketingWindow;
   import Widgets.Windows.MOTD.FarmRunQuestsMOTDWindow;
   import Widgets.Windows.MOTD.FarmRunV5PremarketingWindow;
   import Widgets.Windows.MOTD.FarmRunv4PremarketingWindow;
   import Widgets.Windows.MOTD.FarmersMarket2020MOTD;
   import Widgets.Windows.MOTD.FarmstamaticMOTDWindow;
   import Widgets.Windows.MOTD.FarmvilleAnniversaryV10BirthdayCard;
   import Widgets.Windows.MOTD.FarmvilleAnniversaryV10DecorateBarn;
   import Widgets.Windows.MOTD.FastFarmTravelMOTDWindow;
   import Widgets.Windows.MOTD.FinishAllBuildingsMOTDWindow;
   import Widgets.Windows.MOTD.FishingV2MOTDWindow;
   import Widgets.Windows.MOTD.FishingV2WaterTileMOTDWindow;
   import Widgets.Windows.MOTD.GenericCharityMOTDWindow;
   import Widgets.Windows.MOTD.GenericCloseButtonWidgetMOTD;
   import Widgets.Windows.MOTD.GenericSingleButtonWidgetMOTD;
   import Widgets.Windows.MOTD.GypsyTraderWidgetMOTDWindow;
   import Widgets.Windows.MOTD.HCXPromoMOTDWindow;
   import Widgets.Windows.MOTD.HalloweenInnovationPreMarketingMOTDWindow;
   import Widgets.Windows.MOTD.HalloweenUSAInnovationMOTD;
   import Widgets.Windows.MOTD.IncentivizedEventMOTDWindow;
   import Widgets.Windows.MOTD.IsraelInnovationMOTDWindow;
   import Widgets.Windows.MOTD.ItemContestMOTDWindow;
   import Widgets.Windows.MOTD.JMMOTDWindow;
   import Widgets.Windows.MOTD.JanInnovationPremarketingMOTD;
   import Widgets.Windows.MOTD.JapanAchievementMOTDWindow;
   import Widgets.Windows.MOTD.JuneInnovationPremarketingMOTD;
   import Widgets.Windows.MOTD.LandBundleAlaskaComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleAmsterdamComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleCaribbeanComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleIsraelComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleMOTD;
   import Widgets.Windows.MOTD.LandBundleMadagascarComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundlePumpkinComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleSantavillageComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleSouthindiaComingSoonMOTD;
   import Widgets.Windows.MOTD.LandBundleWinternordComingSoonMOTD;
   import Widgets.Windows.MOTD.LightningDealMotd;
   import Widgets.Windows.MOTD.LimitedQuantityBundleMOTD;
   import Widgets.Windows.MOTD.LongWeekEndDelightMOTD;
   import Widgets.Windows.MOTD.MadagascarInnovationMOTDWindow;
   import Widgets.Windows.MOTD.MinidartsWidgetMOTDWindow;
   import Widgets.Windows.MOTD.MoneyTreeMOTDWindow;
   import Widgets.Windows.MOTD.MultiPanelMOTDWindow;
   import Widgets.Windows.MOTD.MultiRewardTreasurePayerBundleMOTD;
   import Widgets.Windows.MOTD.MysteryCrateMOTDWindow;
   import Widgets.Windows.MOTD.MystreeBabiesMOTDwindow;
   import Widgets.Windows.MOTD.MystreeReskinMOTDWindow;
   import Widgets.Windows.MOTD.MystreeWidgetMOTDWindow;
   import Widgets.Windows.MOTD.NeighborCleanupMOTDWindow;
   import Widgets.Windows.MOTD.PerformancePromotionWidgetMOTD;
   import Widgets.Windows.MOTD.PetAcademyMOTD;
   import Widgets.Windows.MOTD.PreMasteryReductionMOTDWindow;
   import Widgets.Windows.MOTD.RewardCardsMOTDWindow;
   import Widgets.Windows.MOTD.RoyaltyLoyaltyProgramMOTDWindow;
   import Widgets.Windows.MOTD.RussiaInnovationMOTDWindow;
   import Widgets.Windows.MOTD.SlingoXPromoMOTDWindow;
   import Widgets.Windows.MOTD.SocialRaffleMOTDWindow;
   import Widgets.Windows.MOTD.SouthindiaInnovationMOTDWindow;
   import Widgets.Windows.MOTD.StoryBookMOTDWindow;
   import Widgets.Windows.MOTD.SubscriberWalletMotd;
   import Widgets.Windows.MOTD.SubscriberWalletNewRewardsMOTD;
   import Widgets.Windows.MOTD.SubscriptionAllBenefitsMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionDailyBenefitsMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionPostFCBuyMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionRevampExMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionRevampSubscirbersMOTDWindow;
   import Widgets.Windows.MOTD.SubscriptionVipItemsMotdWindow;
   import Widgets.Windows.MOTD.TemplatizedCloseButtonWidgetMOTD;
   import Widgets.Windows.MOTD.TemplatizedSingleButtonWidgetMOTD;
   import Widgets.Windows.MOTD.TropicalMarketMOTD;
   import Widgets.Windows.MOTD.TuscanyInnovationMOTDWindow;
   import Widgets.Windows.MOTD.TwentiesInnovationMOTDWindow;
   import Widgets.Windows.MOTD.TwitterIntegrationWindow;
   import Widgets.Windows.MOTD.UGCItemMOTDWindow;
   import Widgets.Windows.MOTD.UgcFishWidgetMOTDWindow;
   import Widgets.Windows.MOTD.UltimateStarterPackMOTD;
   import Widgets.Windows.MOTD.UnlimitedPacksMOTDWindow;
   import Widgets.Windows.MOTD.WanderingPirateWidgetMOTDWindow;
   import Widgets.Windows.MOTD.WinterInnovationPremarketingMOTD;
   import Widgets.Windows.MOTD.WinterRacingMOTD;
   import Widgets.Windows.MOTD.WinternordInnovationMOTDWindow;
   import Widgets.Windows.MOTD.WorldSpecificSaleMOTDWindow;
   import Widgets.Windows.MOTD.XBLInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XBOPremarketingWidgetMOTD;
   import Widgets.Windows.MOTD.XDVInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XHFInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XHXInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XIDInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XISInnovationPremarketingWindow;
   import Widgets.Windows.MOTD.XMASInnovationMotd;
   import Widgets.Windows.MOTD.XPromoMOTDWindow;
   import Widgets.Windows.MOTD.XRTPremarketingWindow;
   import Widgets.Windows.MOTD.XTIPremarketingWidgetMOTDWindow;
   import Widgets.Windows.MOTD.XWXPremarketingWindow;
   import Widgets.Windows.NeighborCleanupWindow;
   import flash.utils.getDefinitionByName;
   
   public class CustomWindowMOTDHandler extends RepeatableMOTDHandler
   {
      
      private static const CUSTOM_WINDOW_MOTD_PACKAGE:String = "Widgets.Windows.MOTD.";
      
      private static const KEY_WINDOW_TYPE:String = "windowType";
      
      private static const CLASS_REFERENCES:Array = [EdibleSchoolyardMOTDWindow,GenericSingleButtonWidgetMOTD,EdibleSchoolyardMOTDWindow,HCXPromoMOTDWindow,CPAFlowerOfferMOTDWindow,UGCItemMOTDWindow,SlingoXPromoMOTDWindow,CustomMarketMOTDWindow,WinterInnovationPremarketingMOTD,FarmExpressMOTDWindow,FBPermissionRequestMOTDWindow,IncentivizedEventMOTDWindow,JanInnovationPremarketingMOTD,AntiqueMuseumMOTDWindow,JuneInnovationPremarketingMOTD,CheckRequireOnShowMOTDWindow,CommunityV2MOTDWindow,AmexTreeMOTDWindow,RewardCardsMOTDWindow,FastFarmTravelMOTDWindow,BuyFromFeedsOfferWindow,AmexMOTDV2Window,FinishAllBuildingsMOTDWindow,TwitterIntegrationWindow,FarmstamaticMOTDWindow,ItemContestMOTDWindow,XPromoMOTDWindow,MultiPanelMOTDWindow,StoryBookMOTDWindow,MysteryCrateMOTDWindow,NeighborCleanupWindow,CategorySpecificSaleMOTDWindow,WorldSpecificSaleMOTDWindow,LimitedQuantityBundleMOTD,ChristmasCharityBundleMOTD,FarmRunQuestsMOTDWindow,NeighborCleanupMOTDWindow,MoneyTreeMOTDWindow,MystreeBabiesMOTDwindow
      ,LongWeekEndDelightMOTD,UltimateStarterPackMOTD,GenericCharityMOTDWindow,MystreeWidgetMOTDWindow,CommunityGoalsMOTDWindow,WanderingPirateWidgetMOTDWindow,MystreeReskinMOTDWindow,BobBerryWidgetMOTDWindow,MinidartsWidgetMOTDWindow,UnlimitedPacksMOTDWindow,DiamondSubscriptionMOTDWindow,SubscriptionVipItemsMotdWindow,DragonBreedingMOTDWindow,DragonBreedingEventMOTDWindow,ClickToAnimateSingleButtonMOTD,PreMasteryReductionMOTDWindow,GypsyTraderWidgetMOTDWindow,DreamFishDesignerWidgetMOTDWindow,XTIPremarketingWidgetMOTDWindow,XDVInnovationPremarketingWindow,XWXPremarketingWindow,XRTPremarketingWindow,XISInnovationPremarketingWindow,XIDInnovationPremarketingWindow,XHFInnovationPremarketingWindow,FarmRun2018PremarketingWindow,XHXInnovationPremarketingWindow,GenericCloseButtonWidgetMOTD,TemplatizedCloseButtonWidgetMOTD,TemplatizedSingleButtonWidgetMOTD,JapanAchievementMOTDWindow,AFInnovationMarketingMOTDWindow,PerformancePromotionWidgetMOTD,JMMOTDWindow,MultiRewardTreasurePayerBundleMOTD,RoyaltyLoyaltyProgramMOTDWindow
      ,SocialRaffleMOTDWindow,SubscriptionRevampExMOTDWindow,XBOPremarketingWidgetMOTD,FarmRun2018PremarketingWindow,FarmRunv4PremarketingWindow,SubscriptionDailyBenefitsMOTDWindow,SubscriptionAllBenefitsMOTDWindow,SubscriptionRevampSubscirbersMOTDWindow,SubscriptionPostFCBuyMOTDWindow,XMASInnovationMotd,SubscriberWalletMotd,SubscriberWalletNewRewardsMOTD,LightningDealMotd,UgcFishWidgetMOTDWindow,ExperimentGatedTrailerMOTD,AFInnovationMOTDWindow,HalloweenUSAInnovationMOTD,BrInnovationPremarketingMOTDWindow,LandBundleComingSoonMOTD,LandBundleMOTD,LandBundleCaribbeanComingSoonMOTD,LandBundleIsraelComingSoonMOTD,LandBundleSouthindiaComingSoonMOTD,LandBundleSantavillageComingSoonMOTD,LandBundleAlaskaComingSoonMOTD,TuscanyInnovationMOTDWindow,FishingV2MOTDWindow,RussiaInnovationMOTDWindow,IsraelInnovationMOTDWindow,WinternordInnovationMOTDWindow,TwentiesInnovationMOTDWindow,CocowonderlandInnovationMOTDWindow,SouthindiaInnovationMOTDWindow,LandBundleWinternordComingSoonMOTD,LandBundleMadagascarComingSoonMOTD
      ,LandBundleAmsterdamComingSoonMOTD,LandBundlePumpkinComingSoonMOTD,HalloweenInnovationPreMarketingMOTDWindow,HalloweenInnovationPreMarketingMOTDWindow,PetAcademyMOTD,XBLInnovationPremarketingWindow,FarmRunV5PremarketingWindow,FarmvilleAnniversaryV10BirthdayCard,FarmvilleAnniversaryV10DecorateBarn,FishingV2WaterTileMOTDWindow,FVTECurrencyMOTD,AnimalSanctuaryMOTD,WinterRacingMOTD,FarmersMarket2020MOTD,MadagascarInnovationMOTDWindow,BoraboraInnovationMOTD,BoraboraInnovationPremarketingWindow,AnimalSanctuaryV2MOTD,AntiqueMuseumV2MOTD,TropicalMarketMOTD,BoatRushMOTD,FVSunsetMOTD];
      
      private var CUSTOM_WINDOW_PARAMS:String = "customWindowParams";
      
      protected var m_windowParams:Object = null;
      
      public function CustomWindowMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(currentMOTD.hasOwnProperty(this.CUSTOM_WINDOW_PARAMS))
         {
            this.m_windowParams = currentMOTD[this.CUSTOM_WINDOW_PARAMS];
         }
      }
      
      override public function execute() : void
      {
         var windowClassName:String = null;
         var windowClass:Class = null;
         var windowInst:CustomWindowMOTDBase = null;
         if(m_currentMOTD.hasOwnProperty(KEY_WINDOW_TYPE))
         {
            windowClassName = CUSTOM_WINDOW_MOTD_PACKAGE + String(m_currentMOTD[KEY_WINDOW_TYPE]);
            try
            {
               windowClass = getDefinitionByName(windowClassName) as Class;
               windowInst = null;
               if(this.m_windowParams != null)
               {
                  windowInst = new windowClass(this.m_windowParams);
               }
               else
               {
                  windowInst = new windowClass();
               }
               windowInst.currentMOTD = m_currentMOTD;
               windowInst.acceptCallback = acceptMOTD;
               windowInst.cancelCallback = closeMOTD;
               UI.displayPopup(windowInst);
               ztrack("impressions");
               Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
            }
            catch(err:Error)
            {
               ErrorManager.addError("Error instantiating " + windowClassName + ". " + err.message);
            }
         }
         else
         {
            ErrorManager.addError("Invalid MOTD declaraction, " + KEY_WINDOW_TYPE + " missing");
         }
         m_isFinished = true;
      }
   }
}

