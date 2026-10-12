package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryPackagesBuyWindow extends FarmWindow
   {
      
      protected static const X:String = "x";
      
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
      
      private const ICON_URL:Array = ["sanctuaryfoodcoupon","sanctuaryhabitatcoupon","sanctuaryhealthcoupon"];
      
      private var m_buy_mc_name_array:Array = ["buy_mc_0","buy_mc_1","buy_mc_2","buy_mc_3","buy_mc_4","buy_mc_5","buy_mc_6","buy_mc_7","buy_mc_8"];
      
      private var m_buy_mc_array:Array = [];
      
      private var m_buy_bt_array:Array = [];
      
      private var m_count_tf_array:Array = [];
      
      private var m_icon_mc_array:Array = [];
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_bucketPackages:Array;
      
      private var m_coupon:int = -1;
      
      private var m_owner:FarmWindow;
      
      public function AnimalSanctuaryPackagesBuyWindow(dialogPath:String, featureName:String, couponInd:*, owner:FarmWindow = null)
      {
         this.m_featureName = featureName;
         this.m_owner = owner;
         this.m_coupon = couponInd;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary"),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],"Special deals on the coupons! Just for you!"),true) as ZwTextField;
         }
         for(var i:int = 0; i < 9; i++)
         {
            if(m_window.hasOwnProperty(this.m_buy_mc_name_array[i]))
            {
               this.m_buy_mc_array[i] = m_window[this.m_buy_mc_name_array[i]] as MovieClip;
               this.m_buy_mc_array[i].visible = true;
            }
            if(this.m_buy_mc_array[i].hasOwnProperty(this.SLOT_BUY_BTN))
            {
               this.m_buy_bt_array[i] = new FarmAnimatedCashButton(this.m_buy_mc_array[i][this.SLOT_BUY_BTN],"Buy",this.manager.COUPON_COST[i % 3],this.buyPackage(i));
               this.m_buy_bt_array[i].visible = true;
            }
            if(this.m_buy_mc_array[i].hasOwnProperty(this.SLOT_COUNT_TF))
            {
               this.m_count_tf_array[i] = new ZwTextField(this.m_buy_mc_array[i][this.SLOT_COUNT_TF],"x" + this.manager.COUPON_COUNT[i % 3]);
               this.m_count_tf_array[i].visible = true;
            }
            if(this.m_buy_mc_array[i].hasOwnProperty(this.SLOT_ICON_MC))
            {
               this.m_icon_mc_array[i] = new FarmIcon(this.m_buy_mc_array[i][this.SLOT_ICON_MC],this.getSlotIcon(i));
               this.m_icon_mc_array[i].visible = true;
            }
         }
      }
      
      private function getSlotIcon(index:int) : String
      {
         var iconUrl:String = "";
         if(index < 3)
         {
            iconUrl = "assets/dialogs/Animal_sanctury_2019/" + this.ICON_URL[0] + "_icon.png";
         }
         else if(index < 6)
         {
            iconUrl = "assets/dialogs/Animal_sanctury_2019/" + this.ICON_URL[1] + "_icon.png";
         }
         else
         {
            iconUrl = "assets/dialogs/Animal_sanctury_2019/" + this.ICON_URL[2] + "_icon.png";
         }
         return iconUrl;
      }
      
      private function returnCouponTypeBySlot(index:int) : int
      {
         var couponInd:int = 0;
         if(index < 3)
         {
            couponInd = 0;
         }
         else if(index < 6)
         {
            couponInd = 1;
         }
         else
         {
            couponInd = 2;
         }
         return couponInd;
      }
      
      override protected function release() : void
      {
         this.m_titleTf = null;
         this.m_bodyTf = null;
         this.m_bucketPackages = null;
         this.m_owner = null;
         super.release();
      }
      
      public function buyPackage(slot:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var confirmationText:* = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmationAnimalSanctuary",{"price":manager.COUPON_COST[slot % 3]});
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,onAcceptSkipConfirmation(slot),"farmAnimatedCashConfirmation",true,true))
            {
               m_buy_bt_array[slot].enabled = false;
               m_owner.tintWindow();
               m_owner.enableInput = false;
            }
         };
      }
      
      public function onAcceptSkipConfirmation(slot:int) : Function
      {
         return function(evt:GenericPopupEvent):void
         {
            if(evt.button == GenericPopup.ACCEPT)
            {
               manager.buyCoupons(returnCouponTypeBySlot(slot),slot % 3);
            }
            else
            {
               m_owner.untintWindow();
               m_owner.enableInput = true;
            }
            m_buy_bt_array[slot].enabled = true;
         };
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
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

