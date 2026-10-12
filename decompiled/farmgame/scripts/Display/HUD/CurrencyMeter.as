package Display.HUD
{
   import Classes.Constants.QuestConstants;
   import Display.Dialogs.InGameCurrencyConversion;
   import Display.FarmGameSprite;
   import Display.GenericButton;
   import Engine.Managers.LoadingManager;
   import Managers.HangingGardensManager;
   import Widgets.Constants.Market.Currency;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class CurrencyMeter extends FarmGameSprite
   {
      
      private var m_button:GenericButton;
      
      private var m_currencyUnit:String;
      
      private var m_currencyValueTf:TextField;
      
      public function CurrencyMeter(currencyMeterConfig:Object)
      {
         super();
         this.m_currencyUnit = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
         LoadingManager.load(Global.getAssetURL(currencyMeterConfig["path"]),this.onAssetLoaded,LoadingManager.PRIORITY_HIGH);
         if(currencyMeterConfig.hasOwnProperty("x"))
         {
            this.x = currencyMeterConfig.x;
         }
         if(currencyMeterConfig.hasOwnProperty("y"))
         {
            this.y = currencyMeterConfig.y;
         }
         if(currencyMeterConfig.hasOwnProperty("trackClicks") && (currencyMeterConfig.trackClicks == true && currencyMeterConfig.trackClicks == "true"))
         {
            this.trackClicks(true);
         }
         else
         {
            this.trackClicks(false);
         }
      }
      
      public function onAssetLoaded(event:Event) : void
      {
         var meterAsset:MovieClip = event.target.content as MovieClip;
         if(Boolean(meterAsset) && Boolean(meterAsset.currency_bt) && Boolean(meterAsset.currency_bt.currencyValue_tf))
         {
            this.addChild(meterAsset);
            this.m_currencyValueTf = meterAsset.currency_bt.currencyValue_tf as TextField;
            if(this.m_currencyUnit != Currency.GOLD && this.m_currencyUnit != Currency.COINS)
            {
               this.m_button = new GenericButton(meterAsset.currency_bt,this.onClick);
            }
         }
         Global.hud.lockVisualEffectsForNextUpdate();
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      public function get textField() : TextField
      {
         return this.m_currencyValueTf;
      }
      
      public function release() : void
      {
         this.m_button = null;
         this.m_currencyValueTf = null;
      }
      
      private function onClick(event:Event) : void
      {
         switch(this.m_currencyUnit)
         {
            case QuestConstants.REWARD_TROWELS:
               HangingGardensManager.instance.showPostTutorialDialog();
               break;
            default:
               InGameCurrencyConversion.showImpulseBuy(this.m_currencyUnit);
         }
      }
   }
}

