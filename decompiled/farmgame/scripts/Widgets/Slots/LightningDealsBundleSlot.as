package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.LightningDealManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.LightningDealsViewBundle;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LightningDealsBundleSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var icon:MovieClip;
      
      private var barFill:MovieClip;
      
      private var bar:MovieClip;
      
      private var m_viewBt:FarmAnimatedTextButton = null;
      
      private var m_buyBt:FarmAnimatedCashButton = null;
      
      private var m_buyBtAdded:Boolean = false;
      
      private var m_bundleTf:ZwTextField = null;
      
      private var m_claimedTf:ZwTextField = null;
      
      private var m_mysteryTf:ZwTextField = null;
      
      private var m_bundleItem:FarmItem = null;
      
      private var m_bundleIndex:int = 0;
      
      private var m_bundleCost:int = 0;
      
      public function LightningDealsBundleSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         this.bar = m_element["bar_mc"] as MovieClip;
         this.barFill = this.bar["bar_fill_mc"] as MovieClip;
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.icon = m_element["icon_mc"] as MovieClip;
         }
         var x:ZwFrame = m_element as ZwFrame;
         if(x)
         {
            x.removeAllWidgets();
         }
         if(m_element.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_viewBt = new FarmAnimatedTextButton(m_element["view_bt"],"View Content",this.viewBundle));
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buyBt = new FarmAnimatedCashButton(m_element["buy_bt"],"Buy","00",this.buyBundle,false,false,true,""));
            this.m_buyBtAdded = true;
         }
         if(m_element.hasOwnProperty("bundle_tf"))
         {
            addWidget(this.m_bundleTf = new ZwTextField(m_element["bundle_tf"],"Bundle"),true);
         }
         if(m_element.hasOwnProperty("claimed_tf"))
         {
            addWidget(this.m_claimedTf = new ZwTextField(m_element["claimed_tf"],"0% claimed"),true);
         }
         if(m_element.hasOwnProperty("mystery_tf"))
         {
            addWidget(this.m_mysteryTf = new ZwTextField(m_element["mystery_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_curious")),true);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_bundleItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         this.m_bundleIndex = data.index;
         this.m_bundleCost = data.cost;
         var presentDealTab:Boolean = LightningDealManager.getInstance().selectedTab == 1;
         var claimPercent:int = data.factor * LightningDealManager.getInstance().claimPercent;
         if(data.maxCap > 0 && claimPercent > data.maxCap)
         {
            claimPercent = int(data.maxCap);
         }
         else if(claimPercent > 100)
         {
            claimPercent = 100;
         }
         if(this.barFill)
         {
            this.barFill.width = claimPercent;
            this.bar.visible = presentDealTab;
         }
         if(this.icon)
         {
            this.icon.gotoAndStop(Boolean(data.bought) && presentDealTab ? 2 : 1);
            this.icon.visible = true;
         }
         if(this.m_viewBt)
         {
            this.m_viewBt.visible = this.m_bundleIndex != 6 || this.m_bundleIndex == 6 && LightningDealManager.getInstance().selectedTab == 0;
         }
         if(this.m_mysteryTf)
         {
            this.m_mysteryTf.visible = LightningDealManager.getInstance().selectedTab == 2;
         }
         if(this.m_bundleTf)
         {
            this.m_bundleTf.text = this.m_bundleItem.friendlyTitle;
            this.m_bundleTf.visible = true;
         }
         if(this.m_claimedTf)
         {
            this.m_claimedTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_claimed",{"percent":claimPercent.toString()});
            this.m_claimedTf.visible = presentDealTab;
         }
         if(this.m_buyBt)
         {
            this.m_buyBt.visible = presentDealTab;
            this.m_buyBt.enabled = claimPercent != 100;
            this.m_buyBt.setAmountText(this.m_bundleCost.toString());
         }
      }
      
      private function viewBundle(event:Event) : void
      {
         UI.displayPopup(new LightningDealsViewBundle(this.m_bundleItem),false);
         FarmStatsManager.count("lightning_deals","View",this.m_bundleItem.name);
      }
      
      private function buyBundle(event:Event) : void
      {
         this.m_buyBt.enabled = false;
         var cost:int = this.m_bundleItem.realCashCost;
         if(Global.player.canBuyCash(this.m_bundleCost))
         {
            Global.player.cash -= this.m_bundleCost;
            LightningDealManager.getInstance().bundleIndexBoughtInDeal = this.m_bundleIndex;
            TransactionManager.addTransaction(new TGenericTransaction("LightningDealService","buyBundle",this.buyCallback,["lightning_deals",this.m_bundleItem.code]));
            FarmStatsManager.count("lightning_deals","Buy",this.m_bundleItem.name);
            FarmStatsManager.count("fv_cash_buy",this.m_featureName,this.m_bundleItem.name,this.m_bundleCost.toString());
         }
      }
      
      private function buyCallback(result:Object) : void
      {
         if(result.hasOwnProperty("reward"))
         {
            LightningDealManager.getInstance().updateOnRewardBuy(this.m_bundleItem.friendlyTitle,result["reward"]);
            if(this.m_buyBt)
            {
               this.m_buyBt.enabled = true;
            }
            if(this.icon)
            {
               this.icon.gotoAndStop(2);
            }
         }
      }
   }
}

