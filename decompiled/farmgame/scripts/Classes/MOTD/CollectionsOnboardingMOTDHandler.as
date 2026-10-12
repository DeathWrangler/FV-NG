package Classes.MOTD
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Widgets.Windows.Collections.CollectionsWindow;
   
   public class CollectionsOnboardingMOTDHandler extends MOTDHandler
   {
      
      private static const PERMANENT_REQUIRED_COLLECTIBLES:Number = 6;
      
      private static const LIGHNING_REQUIRED_COLLECTIBLES:Number = 47;
      
      private static const PERMANENT_COINS_PRIZE:Number = 5000;
      
      private static const PERMANENT_XP_PRIZE:Number = 250;
      
      private static const LIGHTNING_COINS_PRIZE:Number = 10000;
      
      protected static const MOTD_DIALOG_NAME_NORMAL:String = "Motdspringbasket2011";
      
      private static const ONBOARD_DIALOG_URL:String = "assets/dialogs/4d_elements/Collections/Collections_onboarding.png";
      
      public function CollectionsOnboardingMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var xmlCollection:XML = null;
         var params:Array = null;
         var displayPopup:DataDrivenOkayPopup = null;
         var collection:Collection = null;
         var title:String = ZLocUtils.t("Dialogs","MOTD_Collections_Title");
         var text:String = "";
         var buttonText:String = "";
         var flowPrefix:String = "";
         var totalCoins:Number = 0;
         var totalXP:Number = 0;
         var allCollectionsXML:XMLList = Global.farmGameSettingsManager.getCollections();
         for each(xmlCollection in allCollectionsXML)
         {
            collection = new Collection(xmlCollection);
            totalXP += this.evaluateXPReward(collection);
            totalCoins += this.evaluateCoinsReward(collection);
         }
         totalXP = Global.player.calculateAndAddXp(totalXP);
         text = ZLocUtils.t("Dialogs","MOTD_Collections_Onboarding_Text",{
            "cashQuantity":totalCoins,
            "xpQuantity":totalXP
         });
         buttonText = ZLocUtils.t("Dialogs","MOTD_Collections_Onboarding_ButtonText");
         Global.player.gold += totalCoins;
         params = [ONBOARD_DIALOG_URL,text,title,buttonText];
         displayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NORMAL,params,this.acceptMOTD);
         UI.displayPopup(displayPopup,false);
         super.execute();
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         UI.displayPopup(new CollectionsWindow());
      }
      
      private function evaluateXPReward(collection:Collection) : Number
      {
         var totCollectibles:Number = NaN;
         var ratio:Number = NaN;
         var result:Number = 0;
         if(collection.type == Collection.TYPE_PERMANENT)
         {
            totCollectibles = collection.getCurrentUniqueCollectablesCount();
            ratio = totCollectibles / PERMANENT_REQUIRED_COLLECTIBLES;
            result = Math.round(PERMANENT_XP_PRIZE * ratio);
         }
         return result;
      }
      
      private function evaluateCoinsReward(collection:Collection) : Number
      {
         var totCollectibles:Number = NaN;
         var ratio:Number = NaN;
         var missingCollectibles:Number = NaN;
         var collectIndex:int = 0;
         var currCollectible:Collectible = null;
         var result:Number = 0;
         if(collection.type == Collection.TYPE_PERMANENT)
         {
            totCollectibles = collection.getCurrentUniqueCollectablesCount();
            ratio = totCollectibles / PERMANENT_REQUIRED_COLLECTIBLES;
            result = Math.round(PERMANENT_COINS_PRIZE * ratio);
         }
         else if(collection.type == Collection.TYPE_LIGHTNING)
         {
            missingCollectibles = 0;
            for(collectIndex = 0; collectIndex < 6; collectIndex++)
            {
               currCollectible = collection.getCollectableByIndex(collectIndex);
               if(currCollectible)
               {
                  if(null == Global.player.collectionCounters[currCollectible.code])
                  {
                     missingCollectibles += currCollectible.numNeeded;
                  }
                  if(Global.player.collectionCounters[currCollectible.code] < currCollectible.numNeeded)
                  {
                     missingCollectibles = Math.max(0,currCollectible.numNeeded - Global.player.collectionCounters[currCollectible.code]);
                  }
               }
            }
            ratio = (LIGHNING_REQUIRED_COLLECTIBLES - missingCollectibles) / LIGHNING_REQUIRED_COLLECTIBLES;
            result = Math.round(LIGHTNING_COINS_PRIZE * ratio);
         }
         return result;
      }
   }
}

