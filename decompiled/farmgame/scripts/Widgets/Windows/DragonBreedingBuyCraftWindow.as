package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class DragonBreedingBuyCraftWindow extends FarmWindow
   {
      
      protected static const X:String = "x";
      
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
      
      protected var m_craftItem:String = DragonBreedingManager.HERB_ITEM_NAME;
      
      private var m_owner:DragonBreedingWindow;
      
      public function DragonBreedingBuyCraftWindow(dialogPath:String, featureName:String = null, craftItem:String = "herbsoflove", owner:DragonBreedingWindow = null)
      {
         this.m_featureName = featureName;
         this.m_craftItem = craftItem;
         this.m_owner = owner;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + this.m_craftItem + "_CraftBuyWindow_title")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_" + this.m_craftItem + "_BuyWindow_body")),true) as ZwTextField;
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
      
      override protected function release() : void
      {
         this.m_craftItem = null;
         super.release();
      }
      
      override public function close() : void
      {
         super.close();
         if(this.m_owner)
         {
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
   }
}

