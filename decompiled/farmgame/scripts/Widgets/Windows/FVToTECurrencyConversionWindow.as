package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HudBottomFVTECurrencyConversionButton;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.SubscriptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   
   public class FVToTECurrencyConversionWindow extends FarmWindow
   {
      
      private static var m_FVTEHud:HudBottomFVTECurrencyConversionButton;
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private static const SERVICE_NAME:String = "PumpkinPartyInnovationService";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_CURRENCY_LINK:String = "TROPIC_ESCAPE_CURRENCY_LINK";
      
      protected var m_featureName:String = null;
      
      protected var m_offer_id:int = 0;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var body_tf:ZwTextField;
      
      protected var body1_tf:ZwTextField;
      
      protected var m_bonus_mc:MovieClip;
      
      private var FLAG_TROPIC_ESCAPE_FIRST_TRAVEL:String = "FVTE_CURRENCY_tropic_escape_first_travel";
      
      public var FLAG_TROPIC_CONNECTION_INITIALIZED:String = "FVTE_CURRENCY_tropic_escape_connection_initialized";
      
      public var FLAG_TROPIC_ESCAPE_OFFER_ACCEPTED:String = "FVTE_CURRENCY_OFFER_ACCEPTED";
      
      private var CONSUMABLES_BY_BUCKET:Object = {
         "1":["30","10","1"],
         "2":["50","12","5","1"],
         "3":["100","18","7","2","2"],
         "4":["300","20","10","3","3"],
         "5":["500","20","10","3","3"]
      };
      
      public const CONSUMABLE_COUNT_ARRAY:Array = [10,15,30,40,50];
      
      protected var m_zoomingScale:int = 3;
      
      private var m_tokensUpdateTimer:Timer = null;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_close_bt:FarmAnimatedTextButton;
      
      private var m_no1_tf:ZwTextField;
      
      private var m_no2_tf:ZwTextField;
      
      private var m_no3_tf:ZwTextField;
      
      private var m_no4_tf:ZwTextField;
      
      private var m_no5_tf:ZwTextField;
      
      private var m_sub2_tf:ZwTextField;
      
      private var m_maxDropMc:MovieClip;
      
      private var m_midDropMc:MovieClip;
      
      private var m_lessDropMc:MovieClip;
      
      private var m_mid2DropMc:MovieClip;
      
      public var m_appEnvironment:String = null;
      
      public function FVToTECurrencyConversionWindow(dialogAsset:String, featureName:String, access:String = "")
      {
         super(dialogAsset);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         var bucket:int = 0;
         var totalGems:int = 0;
         var data:Object = null;
         var gemText:String = null;
         super.postLoadComplete();
         if(m_window)
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Loyalty Benefits!"));
            addWidget(new ZwTextField(m_window["sub1_tf"],"Howdy Farmer, based on your FC purchases over the past year we would like to reward you with a huge gift pack in Farmville 2: Tropic Escape. Travel to the Tropic to claim it now!"));
            this.m_sub2_tf = new ZwTextField(m_window["sub2_tf"],"");
            if(m_window.hasOwnProperty("maxdrop_mc"))
            {
               this.m_maxDropMc = m_window["maxdrop_mc"] as MovieClip;
               this.m_maxDropMc.visible = false;
            }
            if(m_window.hasOwnProperty("middrop_mc"))
            {
               this.m_midDropMc = m_window["middrop_mc"] as MovieClip;
               this.m_midDropMc.visible = false;
            }
            if(m_window.hasOwnProperty("lessdrop_mc"))
            {
               this.m_lessDropMc = m_window["lessdrop_mc"] as MovieClip;
               this.m_lessDropMc.visible = false;
            }
            if(m_window.hasOwnProperty("middrop2_mc"))
            {
               this.m_mid2DropMc = m_window["middrop2_mc"] as MovieClip;
               this.m_mid2DropMc.visible = false;
            }
            if(m_window.hasOwnProperty("sub3_tf"))
            {
               addWidget(new ZwTextField(m_window["sub3_tf"],"This offer is open till December 31st 2020."));
            }
            bucket = SubscriptionsManager.getBucketForCurrencyConversion();
            totalGems = 0;
            if(bucket > 0 && bucket <= 5)
            {
               totalGems = this.CONSUMABLE_COUNT_ARRAY[bucket - 1] * 30;
               gemText = "Get " + this.CONSUMABLE_COUNT_ARRAY[bucket - 1] + " gems daily for 30 days = " + totalGems + " gems";
               this.m_sub2_tf.text = gemText;
               this.m_sub2_tf.visible = true;
            }
            data = this.CONSUMABLES_BY_BUCKET[bucket];
            if(bucket >= 4)
            {
               this.m_maxDropMc.visible = true;
               this.m_no1_tf = new ZwTextField(this.m_maxDropMc["no1_tf"],data[0]);
               this.m_no2_tf = new ZwTextField(this.m_maxDropMc["no2_tf"],data[1]);
               this.m_no3_tf = new ZwTextField(this.m_maxDropMc["no3_tf"],data[2]);
               this.m_no4_tf = new ZwTextField(this.m_maxDropMc["no4_tf"],data[3]);
               this.m_no5_tf = new ZwTextField(this.m_maxDropMc["no5_tf"],data[4]);
            }
            else if(bucket == 3)
            {
               this.m_mid2DropMc.visible = true;
               this.m_no1_tf = new ZwTextField(this.m_mid2DropMc["no1_tf"],data[0]);
               this.m_no2_tf = new ZwTextField(this.m_mid2DropMc["no2_tf"],data[1]);
               this.m_no3_tf = new ZwTextField(this.m_mid2DropMc["no3_tf"],data[2]);
               this.m_no4_tf = new ZwTextField(this.m_mid2DropMc["no4_tf"],data[3]);
               this.m_no5_tf = new ZwTextField(this.m_mid2DropMc["no5_tf"],data[4]);
            }
            else if(bucket == 2)
            {
               this.m_midDropMc.visible = true;
               this.m_no1_tf = new ZwTextField(this.m_midDropMc["no1_tf"],data[0]);
               this.m_no2_tf = new ZwTextField(this.m_midDropMc["no2_tf"],data[1]);
               this.m_no3_tf = new ZwTextField(this.m_midDropMc["no3_tf"],data[2]);
               this.m_no4_tf = new ZwTextField(this.m_midDropMc["no4_tf"],data[3]);
            }
            else if(bucket == 1)
            {
               this.m_lessDropMc.visible = true;
               this.m_no1_tf = new ZwTextField(this.m_lessDropMc["no1_tf"],data[0]);
               this.m_no2_tf = new ZwTextField(this.m_lessDropMc["no2_tf"],data[1]);
               this.m_no3_tf = new ZwTextField(this.m_lessDropMc["no3_tf"],data[2]);
            }
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Claim Now!",this.onAccept));
            addWidget(this.m_close_bt = new FarmAnimatedTextButton(m_window["cancel_bt"],"Later!",this.onLater));
            this.m_accept_bt.visible = true;
            this.m_close_bt.visible = true;
         }
      }
      
      private function onAccept(event:Event) : void
      {
         if(!Global.player.getSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL))
         {
            Global.player.setSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL);
         }
         this.initializeTropicEscapeConnection();
         this.travelToTropicEscape();
      }
      
      public function travelToTropicEscape() : void
      {
         var redirectUrl:String = this.getTropicEscapeRedirectUrl();
         redirectUrl += "?miscId=" + String(Global.player.uid);
         navigateToURL(new URLRequest(redirectUrl),"_blank");
         this.close();
         if(Global.hud)
         {
            Global.hud.removeFVTECurrencyHud();
         }
      }
      
      private function onLater(event:Event) : void
      {
         var msg:String = "This offer is open till 31st December, you can come back anytime and claim it! Click on “Icon image” to check the offer again.";
         UI.displayMessage(msg,GenericPopup.TYPE_OK,null,"",true);
         this.close();
      }
      
      private function onSuccessAccept() : *
      {
         var msg:String = "You have Successfully Claimed your rewards in FV Tropical Escape";
         UI.displayMessage(msg,GenericPopup.TYPE_OK,null,"",true);
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      public function initializeTropicEscapeConnection() : void
      {
         this.m_offer_id = SubscriptionsManager.getBucketForCurrencyConversion();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"initializeTropicEscapeCurrencyConversion",this.onTropicEscapeConnectionInitialized,[this.m_offer_id]));
      }
      
      private function onTropicEscapeConnectionInitialized(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = result["response"];
               if(response != null && Boolean(response["data"]["started"]))
               {
                  Global.player.setSeenFlag(this.FLAG_TROPIC_CONNECTION_INITIALIZED);
               }
            }
         }
      }
      
      public function getTropicEscapeRedirectUrl() : String
      {
         var zprodUrl:String = "https://apps.facebook.com/tropic_escape";
         var redirectUrl:String = zprodUrl;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_CURRENCY_LINK) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_CURRENCY_LINK]))
         {
            redirectUrl = Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_CURRENCY_LINK];
         }
         return redirectUrl;
      }
   }
}

