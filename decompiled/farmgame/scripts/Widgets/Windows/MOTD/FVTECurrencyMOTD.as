package Widgets.Windows.MOTD
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.SubscriptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FVToTECurrencyConversionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class FVTECurrencyMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const SERVICE_NAME:String = "PumpkinPartyInnovationService";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_LINK:String = "TROPIC_ESCAPE_LINK";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK:String = "TROPIC_ESCAPE_STAGE_LINK";
      
      private static const START_DATE:String = "Aug 31st 2015";
      
      protected var m_learnMoreLink:ZwButton;
      
      private var m_content:ZwFrame;
      
      private const TILE_NAME:String = "xcl_rubbletreasure_payer12";
      
      private var m_close_bt:FarmAnimatedTextButton;
      
      private var m_FVTECurrencyWindow:FVToTECurrencyConversionWindow;
      
      private var m_no1_tf:ZwTextField;
      
      private var m_no2_tf:ZwTextField;
      
      private var m_no3_tf:ZwTextField;
      
      private var m_no4_tf:ZwTextField;
      
      private var m_no5_tf:ZwTextField;
      
      private var m_maxDropMc:MovieClip;
      
      private var m_midDropMc:MovieClip;
      
      private var m_lessDropMc:MovieClip;
      
      private var m_mid2DropMc:MovieClip;
      
      public var m_appEnvironment:String = null;
      
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
      
      private var m_sub2_tf:ZwTextField;
      
      public function FVTECurrencyMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var bucket:int = 0;
         var totalGems:int = 0;
         var data:Object = null;
         var gemText:String = null;
         if(Boolean(m_window) && m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Loyalty Benefits!"));
            addWidget(new ZwTextField(m_window.mainWindow["sub1_tf"],"Howdy Farmer, based on your FC purchases over the past year we would like to reward you with a huge gift pack in Farmville 2: Tropic Escape. Travel to the Tropic to claim it now!"));
            addWidget(new ZwTextField(m_window.mainWindow["sub3_tf"],"This offer is open till December 31st 2020."));
            this.m_sub2_tf = new ZwTextField(m_window.mainWindow["sub2_tf"],"");
            if(m_window.mainWindow.hasOwnProperty("maxdrop_mc"))
            {
               this.m_maxDropMc = m_window.mainWindow["maxdrop_mc"] as MovieClip;
               this.m_maxDropMc.visible = false;
            }
            if(m_window.mainWindow.hasOwnProperty("middrop_mc"))
            {
               this.m_midDropMc = m_window.mainWindow["middrop_mc"] as MovieClip;
               this.m_midDropMc.visible = false;
            }
            if(m_window.mainWindow.hasOwnProperty("lessdrop_mc"))
            {
               this.m_lessDropMc = m_window.mainWindow["lessdrop_mc"] as MovieClip;
               this.m_lessDropMc.visible = false;
            }
            if(m_window.mainWindow.hasOwnProperty("middrop2_mc"))
            {
               this.m_mid2DropMc = m_window.mainWindow["middrop2_mc"] as MovieClip;
               this.m_mid2DropMc.visible = false;
            }
            if(m_window.mainWindow.close_bt)
            {
               m_window.mainWindow.close_bt.visible = false;
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
            addWidget(m_accept_bt = new FarmAnimatedTextButton(m_window.mainWindow["accept_bt"],"View Offer!",this.onAccept));
            m_accept_bt.visible = true;
         }
      }
      
      private function onClaimNow(event:Event) : void
      {
      }
      
      public function travelToTropicEscape() : void
      {
         var redirectUrl:String = this.getTropicEscapeRedirectUrl();
         redirectUrl += "?miscId=" + String(Global.player.uid);
         navigateToURL(new URLRequest(redirectUrl),"_blank");
         close();
         if(Global.hud)
         {
            Global.hud.removeFVTECurrencyHud();
         }
      }
      
      public function getTropicEscapeRedirectUrl() : String
      {
         var zprodUrl:String = "https://apps.facebook.com/tropic_escape";
         return zprodUrl;
      }
      
      public function initializeTropicEscapeConnection() : void
      {
         var bucket:int = SubscriptionsManager.getBucketForCurrencyConversion();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"initializeTropicEscapeCurrencyConversion",this.onTropicEscapeConnectionInitialized,[bucket]));
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
      
      private function onLater(event:Event) : void
      {
         var msg:String = "This offer is open till 31st December, you can come back anytime and claim it! Click on “Icon image” to check the offer again.";
         UI.displayMessage(msg,GenericPopup.TYPE_OK,null,"",true);
         close();
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.m_FVTECurrencyWindow = new FVToTECurrencyConversionWindow("assets/dialogs/FV_LoyaltyBenefits_2020/FV_LoyaltyBenefits_2020.swf","FVTE","");
         UI.displayPopup(this.m_FVTECurrencyWindow);
         this.close();
      }
   }
}

