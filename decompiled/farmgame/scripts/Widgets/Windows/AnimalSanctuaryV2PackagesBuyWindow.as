package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2PackagesBuyWindow extends FarmWindow
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
      
      private var m_buy_bt_name_array:Array = ["food_pack_0_buy_bt","food_pack_1_buy_bt","food_pack_2_buy_bt","habitat_pack_0_buy_bt","habitat_pack_1_buy_bt","habitat_pack_2_buy_bt","health_pack_0_buy_bt","health_pack_1_buy_bt","health_pack_2_buy_bt"];
      
      private var m_buy_mc_array:Array = [];
      
      private var m_buy_bt_array:Array = [];
      
      private var m_count_tf_array:Array = [];
      
      private var m_icon_mc_array:Array = [];
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_bucketPackages:Array;
      
      private var m_coupon:int = -1;
      
      private var m_owner:FarmWindow;
      
      private var m_subtextTf:ZwTextField;
      
      public function AnimalSanctuaryV2PackagesBuyWindow(dialogPath:String, featureName:String, couponInd:*, owner:FarmWindow = null)
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
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],"Get Coupons"),true) as ZwTextField;
         }
         var animalId:int = this.manager.getSelectedAnimalSlot();
         if(animalId == 1)
         {
            m_window.gotoAndStop(2);
         }
         else if(animalId == 2)
         {
            m_window.gotoAndStop(3);
         }
         else if(animalId == 4)
         {
            m_window.gotoAndStop(1);
         }
         else
         {
            m_window.gotoAndStop(4);
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],"Special deals on the coupons! Just for you!"),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            this.m_subtextTf = addWidget(new ZwTextField(m_window["subtext_tf"],"Special deals on the coupons! Just for you!"),true) as ZwTextField;
         }
         for(var i:int = 0; i < 9; i++)
         {
            if(m_window.hasOwnProperty(this.m_buy_bt_name_array[i]))
            {
               this.m_buy_bt_array[i] = new FarmAnimatedCashButton(m_window[this.m_buy_bt_name_array[i]],"Buy",this.manager.COUPON_COST[i % 3],this.buyPackage(i));
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
            couponInd = 2;
         }
         else
         {
            couponInd = 1;
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
               if(manager.m_packageBuyWindow)
               {
                  manager.m_packageBuyWindow.tintWindow();
                  manager.m_packageBuyWindow.enableInput = false;
               }
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
            else if(manager.m_packageBuyWindow)
            {
               manager.m_packageBuyWindow.untintWindow();
               manager.m_packageBuyWindow.enableInput = true;
            }
            m_buy_bt_array[slot].enabled = true;
         };
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
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

