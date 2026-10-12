package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.IsoMath;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MultiTreasurePayerBundleHoverOverWindow extends MultiTreasureHoverOverWindow
   {
      
      private static const OFFSET_X:int = 200;
      
      private var m_completeNowFirstBundleCallback:Function = null;
      
      private var m_completeNowSecondBundleCallback:Function = null;
      
      private var m_dialogsPrefix:String = "PayerBundleMidWest";
      
      private var m_completeNowFirstBundleBtn:FarmAnimatedCashButton = null;
      
      private var m_completeNowSecondBundleBtn:FarmAnimatedCashButton = null;
      
      private var m_buyFirstBundleMc:MovieClip;
      
      private var m_buySecondBundleMc:MovieClip;
      
      private var m_expiryText:ZwTextField = null;
      
      private var d1Header:ZwTextField = null;
      
      private var d1Description:ZwTextField = null;
      
      private var d1Percent:ZwTextField = null;
      
      private var d1Icon:FarmIcon = null;
      
      private var d1AmountFull:ZwTextField = null;
      
      private var d2Header:ZwTextField = null;
      
      private var d2Description:ZwTextField = null;
      
      private var d2Percent:ZwTextField = null;
      
      private var d2AmountFull:ZwTextField = null;
      
      private var d2Icon:FarmIcon = null;
      
      private var m_timer:Timer;
      
      private var m_bundleDetails:Object = null;
      
      public function MultiTreasurePayerBundleHoverOverWindow(treasure:MultiRewardTreasureConstructionBuilding, allPrereqDetails:Object, callBackObject:Object, timerTime:int = -1, windowAsset:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf", payerTile:Boolean = false, bundleDetails:Object = null)
      {
         super(treasure,allPrereqDetails,callBackObject,timerTime,windowAsset,payerTile);
         this.m_bundleDetails = bundleDetails;
         this.refreshCallbacksForBundle(callBackObject);
      }
      
      override protected function alignWindowOrigin() : void
      {
         var posX:int = 0;
         if(this.m_bundleDetails.showBundleBuyUI == true)
         {
            m_displayPoint = IsoMath.viewportToStage(IsoMath.tilePosToPixelPos(m_originPoint.x,m_originPoint.y));
            posX = (Global.stage.stageWidth - m_window.width) / 2 + OFFSET_X;
            setAbsolutePos(posX,0,true);
         }
         else
         {
            super.alignWindowOrigin();
         }
      }
      
      private function refreshCallbacksForBundle(callBackObject:Object) : void
      {
         if(callBackObject.hasOwnProperty("completeNowFirstBundleCallback") && callBackObject.hasOwnProperty("completeNowSecondBundleCallback"))
         {
            this.m_completeNowFirstBundleCallback = callBackObject["completeNowFirstBundleCallback"];
            this.m_completeNowSecondBundleCallback = callBackObject["completeNowSecondBundleCallback"];
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var temp:MovieClip = null;
         var temp1:MovieClip = null;
         super.postLoadComplete();
         if(this.m_bundleDetails.showBundleBuyUI == true)
         {
            if(m_window.hasOwnProperty("expiry_tf"))
            {
               this.m_expiryText = new ZwTextField(m_window.expiry_tf,"");
            }
            if(m_window.hasOwnProperty("deal1_mc"))
            {
               this.m_buyFirstBundleMc = m_window.deal1_mc as MovieClip;
               this.m_buyFirstBundleMc.visible = true;
               if(this.m_buyFirstBundleMc.hasOwnProperty("header_tf"))
               {
                  this.d1Header = new ZwTextField(this.m_buyFirstBundleMc.header_tf,"");
               }
               if(this.m_buyFirstBundleMc.hasOwnProperty("description_tf"))
               {
                  this.d1Description = new ZwTextField(this.m_buyFirstBundleMc.description_tf,"");
               }
               if(this.m_buyFirstBundleMc.hasOwnProperty("percent_tf"))
               {
                  this.d1Percent = new ZwTextField(this.m_buyFirstBundleMc.percent_tf,"");
               }
               if(this.m_buyFirstBundleMc.hasOwnProperty("image_mc"))
               {
                  addWidget(this.d1Icon = new FarmIcon(this.m_buyFirstBundleMc["image_mc"]),true);
                  this.d1Icon.setIconSize(230,230);
                  this.d1Icon.visible = true;
               }
               if(this.m_buyFirstBundleMc.hasOwnProperty("buy1_bt"))
               {
                  addWidget(this.m_completeNowFirstBundleBtn = new FarmAnimatedCashButton(this.m_buyFirstBundleMc.buy1_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"BuyNow"),"0",this.onClickCompleteFirstBundle),true);
                  temp = this.m_buyFirstBundleMc.buy1_bt as MovieClip;
                  if(temp.hasOwnProperty("amount_full_tf"))
                  {
                     this.d1AmountFull = new ZwTextField(temp.amount_full_tf,"");
                  }
               }
            }
            if(m_window.hasOwnProperty("deal2_mc"))
            {
               this.m_buySecondBundleMc = m_window.deal2_mc as MovieClip;
               m_window.deal2_mc.visible = true;
               if(this.m_buySecondBundleMc.hasOwnProperty("header_tf"))
               {
                  this.d2Header = new ZwTextField(this.m_buySecondBundleMc.header_tf,"");
               }
               if(this.m_buySecondBundleMc.hasOwnProperty("description_tf"))
               {
                  this.d2Description = new ZwTextField(this.m_buySecondBundleMc.description_tf,"");
               }
               if(this.m_buySecondBundleMc.hasOwnProperty("percent_tf"))
               {
                  this.d2Percent = new ZwTextField(this.m_buySecondBundleMc.percent_tf,"");
               }
               if(this.m_buySecondBundleMc.hasOwnProperty("image_mc"))
               {
                  this.d2Icon = new FarmIcon(this.m_buySecondBundleMc["image_mc"]);
                  this.d2Icon.setIconSize(230,230);
                  this.d2Icon.visible = true;
               }
               if(this.m_buySecondBundleMc.hasOwnProperty("buy2_bt"))
               {
                  addWidget(this.m_completeNowSecondBundleBtn = new FarmAnimatedCashButton(this.m_buySecondBundleMc.buy2_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"BuyNow"),"0",this.onClickCompleteSecondBundle),true);
                  temp1 = this.m_buySecondBundleMc.buy2_bt as MovieClip;
                  if(temp1.hasOwnProperty("amount_full_tf"))
                  {
                     this.d2AmountFull = new ZwTextField(temp1.amount_full_tf,"");
                  }
               }
            }
         }
         this.updateBundleUI();
      }
      
      private function updateBundleUI() : void
      {
         var descKeyMidPart:String = null;
         if(this.m_bundleDetails.showBundleBuyUI == true)
         {
            descKeyMidPart = "";
            if(this.m_bundleDetails.secondBundleAvailable)
            {
               if(this.m_bundleDetails.firstBundleAvailable)
               {
                  descKeyMidPart = "Case1";
               }
               else
               {
                  descKeyMidPart = "Case2";
               }
            }
            else
            {
               descKeyMidPart = "Case3";
            }
            if(this.m_expiryText)
            {
               this.m_expiryText.visible = true;
               if(this.m_bundleDetails.daysLeft == 0)
               {
                  if(this.m_timer == null)
                  {
                     this.m_timer = new Timer(1000);
                     this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
                     this.m_timer.start();
                  }
               }
               else
               {
                  this.m_expiryText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_dialogsPrefix + "Case1_centraltitle",{"dayNum":this.m_bundleDetails.daysLeft});
               }
            }
            if(this.d1Header)
            {
               this.d1Header.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_dialogsPrefix + "Case1_lhstitle");
            }
            if(this.d1Description)
            {
               this.d1Description.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_dialogsPrefix + descKeyMidPart + "_lhssubtitle");
            }
            if(this.d1Percent)
            {
               this.d1Percent.text = this.m_bundleDetails.firstBundleDiscount;
            }
            if(this.d1AmountFull)
            {
               this.d1AmountFull.text = this.m_bundleDetails.firstBundleOriginalPrice;
            }
            if(this.d1Icon)
            {
               this.d1Icon.loadIcon(this.m_bundleDetails.firstBundleBG);
            }
            if(this.m_completeNowFirstBundleBtn)
            {
               this.m_completeNowFirstBundleBtn.setAmountText(this.m_bundleDetails.firstBundleDiscountPrice);
               this.m_completeNowFirstBundleBtn.enabled = this.m_bundleDetails.firstBundleAvailable;
            }
            if(this.d2Header)
            {
               this.d2Header.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_dialogsPrefix + "Case1_rhstitle");
            }
            if(this.d2Description)
            {
               this.d2Description.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_dialogsPrefix + descKeyMidPart + "_rhssubtitle");
            }
            if(this.d2Percent)
            {
               this.d2Percent.text = this.m_bundleDetails.secondBundleDiscount;
            }
            if(this.d2AmountFull)
            {
               this.d2AmountFull.text = this.m_bundleDetails.secondBundleOriginalPrice;
            }
            if(this.d2Icon)
            {
               this.d2Icon.loadIcon(this.m_bundleDetails.secondBundleBG);
            }
            if(this.m_completeNowSecondBundleBtn)
            {
               this.m_completeNowSecondBundleBtn.setAmountText(this.m_bundleDetails.secondBundleDiscountPrice);
               this.m_completeNowSecondBundleBtn.enabled = this.m_bundleDetails.secondBundleAvailable;
            }
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = NaN;
         if(Boolean(this.m_expiryText) && this.m_bundleDetails.hasOwnProperty("lastDate"))
         {
            timeRemaining = (this.m_bundleDetails.lastDate - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_expiryText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_dialogsPrefix + "Case1_centraltitle2",{"dayNum":HUD.getformattedTimeLeft(timeRemaining)});
         }
      }
      
      override public function hide() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.hide();
      }
      
      private function onClickCompleteFirstBundle(e:MouseEvent) : void
      {
         this.m_completeNowFirstBundleCallback();
         this.hide();
      }
      
      private function onClickCompleteSecondBundle(e:MouseEvent) : void
      {
         this.m_completeNowSecondBundleCallback();
         this.hide();
      }
      
      public function updateAndShowBundle(treasure:MultiRewardTreasureConstructionBuilding, allPrereqDetails:Object, callBackObject:Object, timerTime:int = -1, payerTile:Boolean = false, firstSecondBundleData:Object = null) : void
      {
         this.m_bundleDetails = firstSecondBundleData;
         updateAndShow(treasure,allPrereqDetails,callBackObject,timerTime,payerTile);
         this.refreshCallbacksForBundle(callBackObject);
         this.updateBundleUI();
      }
   }
}

