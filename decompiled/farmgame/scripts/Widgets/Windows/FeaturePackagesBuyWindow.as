package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class FeaturePackagesBuyWindow extends FarmWindow
   {
      
      protected static const X:String = "x";
      
      protected static const DIALOG_TEXT_SUFFIX:String = "PackagesBuyWindow";
      
      protected static const BUY_BTN_TEXT:String = "MystreeSunshineBuyButtonWindowText";
      
      protected var m_featureName:String = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESC_TF:String = "body_tf";
      
      private const BUY_MC_0:String = "buy_mc_0";
      
      private const BUY_MC_1:String = "buy_mc_1";
      
      private const BUY_MC_2:String = "buy_mc_2";
      
      private const BUY_MC_3:String = "buy_mc_3";
      
      protected const SLOT_BUY_BTN:String = "cashbuy0_bt";
      
      protected const SLOT_COUNT_TF:String = "count_tf_0";
      
      protected const SLOT_ICON_MC:String = "icon_mc_0";
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_bucketPackages:Array;
      
      private var m_owner:FarmWindow;
      
      public function FeaturePackagesBuyWindow(dialogPath:String, featureName:String, itemPackages:Array, owner:FarmWindow = null)
      {
         this.m_featureName = featureName;
         this.m_owner = owner;
         this.m_bucketPackages = itemPackages;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + DIALOG_TEXT_SUFFIX + "_Title")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + DIALOG_TEXT_SUFFIX + "_Body")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.BUY_MC_0))
         {
            this.setupBuySlot(0,m_window[this.BUY_MC_0]);
         }
         if(m_window.hasOwnProperty(this.BUY_MC_1))
         {
            this.setupBuySlot(1,m_window[this.BUY_MC_1]);
         }
         if(m_window.hasOwnProperty(this.BUY_MC_2))
         {
            this.setupBuySlot(2,m_window[this.BUY_MC_2]);
         }
         if(m_window.hasOwnProperty(this.BUY_MC_3))
         {
            this.setupBuySlot(3,m_window[this.BUY_MC_3]);
         }
      }
      
      protected function setupBuySlot(index:Number, mc:MovieClip) : void
      {
         /*
          * Decompilation error
          * Code may be obfuscated
          * Tip: You can try enabling "Deobfuscate code" option in Settings
          * Error type: IndexOutOfBoundsException (Index -1 out of bounds for length 0)
          */
         throw new flash.errors.IllegalOperationError("Not decompiled due to error");
      }
      
      protected function buyItemPackage(buyPackage:String) : void
      {
         var itemPackage:FarmItem = null;
         if(buyPackage != null)
         {
            itemPackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            Global.player.buyFarmItem(itemPackage,Currency.CASH,1,false);
            if(this.m_owner)
            {
               this.m_owner.refreshWindow();
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_titleTf = null;
         this.m_bodyTf = null;
         this.m_bucketPackages = null;
         this.m_owner = null;
         super.release();
      }
      
      override public function close() : void
      {
         if(this.m_owner)
         {
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
         super.close();
      }
   }
}

