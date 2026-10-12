package Managers
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.CrossPromoDescriptor;
   import Classes.CrossPromoDescriptorManager;
   import Classes.CrossPromoSign;
   import Classes.Idle.CrossPromoToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.MapTrigger;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TBeginOutBoundCrossPromo;
   import Transactions.TClaimCrossPromoReward;
   import Transactions.TGetOutBoundPromoUrl;
   import Transactions.TStartOutBoundPromo;
   import Widgets.Windows.CrossPromo.CrossPromoDescriptorWindow;
   import Widgets.Windows.CrossPromo.OutBoundCrossPromoToasterWindow;
   import Widgets.Windows.CrossPromo.ThemedCrossPromoToasterWindow;
   
   public class CrossPromoManager
   {
      
      private static var m_instance:CrossPromoManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private static var m_fuelUsed:int = 0;
      
      private static var m_seenToasterList:Object = new Object();
      
      private var m_mapTriggers:Vector.<MapTrigger>;
      
      public function CrossPromoManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : CrossPromoManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new CrossPromoManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function notifyCanClaimReward(promoIds:Array) : void
      {
         var promoId:String = null;
         for each(promoId in promoIds)
         {
            this.addPromoIconToHud(promoId);
            this.addToaster(promoId);
         }
      }
      
      public function doAvailable() : void
      {
         if(Global.experimentManager.getExperimentVariant(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_EXP) > 0)
         {
            if(!Global.player.getSeenFlag(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID))
            {
               if(this.isWithinShowLimit(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID))
               {
                  if(this.hasEnoughTimeElapsed(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID))
                  {
                     IdleTaskQueue.getInstance().addTask(new CrossPromoToasterIdleTask(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,3));
                     FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"toaster","impressions");
                  }
               }
            }
         }
         this.m_mapTriggers = new Vector.<MapTrigger>();
         this.showOutOfBoundPromo();
      }
      
      public function showOutOfBoundPromo() : void
      {
         var promos:Object;
         var mapTrigger:MapTrigger = null;
         var promo:CrossPromoDescriptor = null;
         var genericPromoSign:CrossPromoSign = null;
         for each(mapTrigger in this.m_mapTriggers)
         {
            mapTrigger.detach();
            mapTrigger = null;
         }
         if(Global.worldManager.isVisitingNPC())
         {
            return;
         }
         promos = Global.crosspromoDescriptorManager.crossPromos;
         for each(promo in promos)
         {
            if(promo.hasBillboard() && !CrossPromoDescriptorManager.getRemoveBillboardSeenFlag(promo))
            {
               if(this.m_mapTriggers != null)
               {
                  genericPromoSign = new CrossPromoSign(promo.billboardItemName,promo.promoName,function(promoName:String):void
                  {
                     var activePromo:* = Global.crosspromoDescriptorManager.getCrossPromo(promoName);
                     var playUrl:* = activePromo.billBoardPlayUrl != null ? activePromo.billBoardPlayUrl : activePromo.playUrl;
                     if(Boolean(activePromo.shouldRedirectOnClick) && Boolean(playUrl != null) && playUrl != "")
                     {
                        GlobalEngine.socialNetwork.redirect(playUrl,null,promo.targetWindow,false);
                     }
                     else
                     {
                        UI.displayPopup(new CrossPromoDescriptorWindow(activePromo));
                     }
                  });
                  genericPromoSign.loadObject(null);
                  this.m_mapTriggers.push(genericPromoSign);
               }
            }
         }
      }
      
      public function notifyCanDoOutBoundPromo(promoIds:Array) : void
      {
         var promoId:String = null;
         var delay:int = 0;
         for each(promoId in promoIds)
         {
            switch(promoId)
            {
               case CrossPromoConstants.MW_XPROMO_1:
                  break;
               case CrossPromoConstants.MW_XPROMO_2:
                  delay = Global.farmGameSettingsManager.getInt("mwXpromoToasterDelaySeconds",10);
                  IdleTaskQueue.getInstance().addTask(new CrossPromoToasterIdleTask(promoId,delay));
            }
            this.addPromoIconToHud(promoId);
         }
      }
      
      public function claimReward(promoId:String) : void
      {
         TransactionManager.addTransaction(new TClaimCrossPromoReward(promoId),true);
      }
      
      public function notifyFuelUse(increment:int = 1) : void
      {
         m_fuelUsed += increment;
         if(m_fuelUsed >= Global.player.energyMax / 2)
         {
            m_fuelUsed = 0;
            this.notifyBeginOutBoundPromo("use_x_fuel");
         }
      }
      
      public function notifyBeginOutBoundPromo(action:String) : void
      {
         TransactionManager.addTransaction(new TBeginOutBoundCrossPromo(action));
      }
      
      public function getOutBoundPromoUrl(promoId:String) : void
      {
         TransactionManager.addTransaction(new TGetOutBoundPromoUrl(promoId),true);
      }
      
      public function startOutBoundPromo(promoId:String) : void
      {
         TransactionManager.addTransaction(new TStartOutBoundPromo(promoId),true);
      }
      
      private function addPromoIconToHud(promoId:String) : void
      {
         Global.hud.iconQueue.addIconToTop(promoId);
      }
      
      public function showToaster(promoId:String) : void
      {
         var message:String = ZLocUtils.t("Dialogs",promoId + "_toasterMessage");
         var title:String = ZLocUtils.t("Dialogs",promoId + "_toasterTitle");
         var dialogAsset:String = CrossPromoConstants.OUTBOUND_TOASTER_URL;
         var bgAssetPath:String = CrossPromoConstants.BASE_BG_PATH + promoId + ".png";
         ToasterManager.getInstance().add(new OutBoundCrossPromoToasterWindow(promoId,message,dialogAsset,title,bgAssetPath));
         m_seenToasterList[promoId] = true;
         Global.player.incrementActionCount(promoId);
         Global.player.setFeatureLastShown(promoId,GlobalEngine.currentTime / 1000,true);
      }
      
      public function toasterClickCallback(promoId:String) : void
      {
         var _loc2_:String = promoId;
         switch(0)
         {
         }
         this.startOutBoundPromo(promoId);
      }
      
      private function addToaster(promoId:String) : void
      {
         var themeXml:XML = Global.farmGameSettingsManager.getWindowThemeXMLByCode(promoId);
         if(themeXml != null)
         {
            ToasterManager.getInstance().add(new ThemedCrossPromoToasterWindow(promoId));
         }
      }
      
      private function isWithinShowLimit(crossPromoName:String) : Boolean
      {
         var showLimit:int = Global.farmGameSettingsManager.getInt(CrossPromoConstants.CROSS_PROMO_SHOW_TOTAL,3);
         var showCount:int = Global.player.getActionCount(crossPromoName);
         return showCount < showLimit;
      }
      
      private function hasEnoughTimeElapsed(crossPromoName:String) : Boolean
      {
         var featureFrequencyTime:Number = Global.farmGameSettingsManager.getInt(crossPromoName + "_" + CrossPromoConstants.CROSS_PROMO_SHOW_FREQUENCY,12);
         var featureLastShown:Number = Global.player.getFeatureLastShown(crossPromoName);
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         return featureLastShown + featureFrequencyTime <= currentTime;
      }
   }
}

