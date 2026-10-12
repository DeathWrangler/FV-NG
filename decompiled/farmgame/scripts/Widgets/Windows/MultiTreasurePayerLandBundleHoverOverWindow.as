package Widgets.Windows
{
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MultiTreasurePayerLandBundleHoverOverWindow extends MultiTreasureHoverOverWindow
   {
      
      private var m_bundleDetails:Object = null;
      
      private var b1:ZwTextField = null;
      
      private var b2:ZwTextField = null;
      
      private var b3:ZwTextField = null;
      
      private var h1:ZwTextField = null;
      
      private var percent:ZwTextField = null;
      
      private var bonusMc:MovieClip;
      
      private var bonusName:ZwTextField = null;
      
      private var buy1:FarmAnimatedCashButton = null;
      
      private var buy2:FarmAnimatedCashButton = null;
      
      private var rewardIcon1:MovieClip;
      
      private var rewardIcon2:MovieClip;
      
      private var reward1Name:ZwTextField = null;
      
      private var reward2Name:ZwTextField = null;
      
      private var buy1AmountFull:ZwTextField = null;
      
      private var m_worldName:String;
      
      private var m_onClickCompleteNow1Callback:Function = null;
      
      private var m_onClickCompleteNow2Callback:Function = null;
      
      public function MultiTreasurePayerLandBundleHoverOverWindow(treasure:MultiRewardTreasureConstructionBuilding, allPrereqDetails:Object, callBackObject:Object, timerTime:int = -1, windowAsset:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf", payerTile:Boolean = false, bundleDetails:Object = null, worldName:String = null)
      {
         super(treasure,allPrereqDetails,callBackObject,timerTime,windowAsset,payerTile);
         this.m_bundleDetails = bundleDetails;
         this.m_worldName = worldName;
         this.refreshCallbacksForBundle(callBackObject);
      }
      
      private function refreshCallbacksForBundle(callBackObject:Object) : void
      {
         if(callBackObject.hasOwnProperty("onClickCompleteNow1"))
         {
            this.m_onClickCompleteNow1Callback = callBackObject["onClickCompleteNow1"];
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var temp1:MovieClip = null;
         super.postLoadComplete();
         if(m_headerTextfield)
         {
            m_headerTextfield.text = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"LandBundle" + this.m_worldName + "Title");
         }
         if(this.m_bundleDetails.type == "bundle")
         {
            addWidget(this.b1 = new ZwTextField(m_window["body1_tf"],"b1"));
            addWidget(this.b2 = new ZwTextField(m_window["body2_tf"],"b2"));
            addWidget(this.b3 = new ZwTextField(m_window["body3_tf"],"b3"));
            addWidget(this.percent = new ZwTextField(m_window["percent_tf"],"35%"));
            this.bonusMc = m_window["bonus_mc"] as MovieClip;
            this.bonusMc.visible = true;
            addWidget(this.buy1 = new FarmAnimatedCashButton(m_window.buy1_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"BuyNow"),"0",this.onClickCompleteNow1));
            addWidget(this.buy2 = new FarmAnimatedCashButton(m_window.buy2_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,"BuyNow"),"0",this.onClickCompleteNow2));
            temp1 = m_window.buy1_bt as MovieClip;
            if(temp1.hasOwnProperty("amount_full_tf"))
            {
               this.buy1AmountFull = new ZwTextField(temp1.amount_full_tf,"");
            }
         }
         else if(this.m_bundleDetails.type == "comingsoon")
         {
            m_subheaderTextfield.text = "coming soon";
            m_completeNowButton.enabled = false;
            m_completeNowButton.visible = false;
         }
         this.updateBundleUI();
      }
      
      private function onClickCompleteNow1(e:MouseEvent) : void
      {
         this.m_onClickCompleteNow1Callback();
         hide();
      }
      
      private function onClickCompleteNow2(e:MouseEvent) : void
      {
         m_completeNowCallback();
         hide();
      }
      
      private function updateBundleUI() : void
      {
         if(this.m_bundleDetails.type == "bundle")
         {
            this.buy1AmountFull.text = "296";
            this.buy1.setAmountText("190");
            this.buy1.enabled = true;
            this.buy2.setAmountText("100");
            this.buy2.setAmountText(m_getCashNeededCallback().toString());
            m_headerTextfield.text = ZLocUtils.t("Dialogs","LandBundle" + this.m_worldName + "Title");
            this.b1.text = ZLocUtils.t("Dialogs","LandBundle" + this.m_worldName + "SubTitle1");
            this.b2.text = ZLocUtils.t("Dialogs","LandBundle" + this.m_worldName + "SubTitle2");
            this.b3.text = "Buy one tile " + m_treasureItem.friendlyTitle;
         }
         else if(this.m_bundleDetails.type == "comingsoon")
         {
            m_subheaderTextfield.text = "coming soon";
            m_headerTextfield.text = ZLocUtils.t("Dialogs","LandBundle" + this.m_worldName + "Title");
            m_subheader2Textfield.text = "Coming Soon";
            m_completeNowButton.enabled = false;
            m_completeNowButton.visible = false;
         }
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

