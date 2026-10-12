package Widgets.Windows
{
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BringBackEasterRewardWindow extends FarmWindow
   {
      
      private var m_featureName:String = "";
      
      private var m_type:String = null;
      
      private var m_isBonus:Boolean = false;
      
      private var COLLECTION_BONUS_REWARD2:String = "Yule Pegasus";
      
      private var COLLECTION_BONUS_REWARD1:String = "Xmas Yearling Unicorn";
      
      private var m_title:FarmTextField;
      
      private var m_subtitle:FarmTextField;
      
      private var m_EasterBenefit_tf:FarmTextField;
      
      private var m_share_tf:FarmTextField;
      
      private var m_bonus1_mc:MovieClip;
      
      private var m_bonus2_mc:MovieClip;
      
      private var m_bonus1Confirm_mc:MovieClip;
      
      private var m_bonus2Confirm_mc:MovieClip;
      
      private var m_name1Tf:FarmTextField;
      
      private var m_name2Tf:FarmTextField;
      
      private var m_name1RewardWindowTf:FarmTextField;
      
      private var m_name2RewardWindowTf:FarmTextField;
      
      private var m_egg1_mc:MovieClip;
      
      private var m_egg2_mc:MovieClip;
      
      private var m_egg1ConfirmMc:MovieClip;
      
      private var m_egg2ConfirmMc:MovieClip;
      
      private var m_select1_bt:FarmAnimatedTextButton;
      
      private var m_select2_bt:FarmAnimatedTextButton;
      
      private var m_and_mc:MovieClip;
      
      private var m_or_mc:MovieClip;
      
      private var m_andMc:MovieClip;
      
      private var m_orMc:MovieClip;
      
      private var m_EasterBenefitMc:MovieClip;
      
      private var m_bonusConfirm_mc:MovieClip;
      
      private var m_easterBenefit_mc:MovieClip;
      
      private var m_share_mc:MovieClip;
      
      private var m_select_mc:MovieClip;
      
      private var m_bonusBothMc:MovieClip;
      
      private var m_bonusSingleMc:MovieClip;
      
      private var bonusToGrant:int = 0;
      
      private var m_callback:Function = null;
      
      private var m_AwesomelButton:FarmAnimatedTextButton;
      
      private var m_EasterBenefitOk_bt:FarmAnimatedTextButton;
      
      private var m_back_bt:FarmAnimatedTextButton;
      
      private var m_confirm_bt:FarmAnimatedTextButton;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      public function BringBackEasterRewardWindow(type:String, featureName:String, callBack:Function = null, isBonus:Boolean = false)
      {
         this.m_type = type;
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_isBonus = isBonus;
         var assetPath:String = BringBackWinterManager.getInstance(this.m_featureName).getRewardDialogPathFor(this.m_type);
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var noOfBonus:int = this.manager.hasBonusBeenGranted();
         var bonusCollection:Array = this.manager.getBonusRewards();
         if(m_window)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               if(noOfBonus > 0)
               {
                  addWidget(this.m_title = new FarmTextField(m_window["generic_tf"],"Congratulations!"),true);
               }
               else
               {
                  addWidget(this.m_title = new FarmTextField(m_window["generic_tf"],"Kringle’s Bonus!"),true);
               }
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               if(noOfBonus == 3)
               {
                  this.bonusToGrant = 3;
                  addWidget(this.m_subtitle = new FarmTextField(m_window["generic2_tf"],"You have won both the rewards! Find them in your Giftbox\nand share this news with your friends!"),true);
               }
               else if(noOfBonus > 0 || this.m_isBonus)
               {
                  addWidget(this.m_subtitle = new FarmTextField(m_window["generic2_tf"],"Spoilt for Choice!\nChoose your Reward"),true);
               }
               else
               {
                  addWidget(this.m_subtitle = new FarmTextField(m_window["generic2_tf"],"Find all the 18 gifts before 14th January, 2019 to choose your favourite Bonus Reward out of the 2 above!"),true);
               }
            }
            if(m_window.hasOwnProperty("EasterBenefitMc") && !this.manager.hasTimeGatePassed())
            {
               this.m_EasterBenefitMc = m_window.EasterBenefitMc as MovieClip;
               this.m_EasterBenefitMc.visible = noOfBonus >= 0 && noOfBonus < 3;
               addWidget(this.m_EasterBenefitOk_bt = new FarmAnimatedTextButton(this.m_EasterBenefitMc.okay_bt,"Okay",this.onOkayClick));
               this.m_EasterBenefitOk_bt.visible = noOfBonus >= 0 && noOfBonus < 3;
               addWidget(this.m_EasterBenefit_tf = new FarmTextField(this.m_EasterBenefitMc["subtitle1_tf"],"Find all the wrapped presents before 30th December, 2018 and win BOTH the Bonus Rewards!"),true);
               if(this.m_EasterBenefitMc.hasOwnProperty("easterBenefit_mc"))
               {
                  this.m_easterBenefit_mc = this.m_EasterBenefitMc.easterBenefit_mc as MovieClip;
                  this.m_easterBenefit_mc.visible = noOfBonus == 0;
               }
            }
            if(m_window.hasOwnProperty("bonusConfirm_mc"))
            {
               this.m_bonusConfirm_mc = m_window.bonusConfirm_mc as MovieClip;
               this.m_bonusConfirm_mc.visible = false;
            }
            if(m_window.hasOwnProperty("share_mc"))
            {
               this.m_share_mc = m_window.share_mc as MovieClip;
               this.m_share_mc.visible = noOfBonus > 0;
               addWidget(this.m_share_bt = new FarmAnimatedTextButton(this.m_share_mc.share_bt,"Share",this.onShareClick));
               this.m_share_bt.visible = true;
            }
            if(m_window.hasOwnProperty("select_mc") && this.manager.hasTimeGatePassed())
            {
               this.m_select_mc = m_window.select_mc as MovieClip;
               this.m_select_mc.visible = this.manager.hasCollectedAllItems() && noOfBonus == 0;
               if(this.m_select_mc.hasOwnProperty("select1_bt"))
               {
                  addWidget(this.m_select1_bt = new FarmAnimatedTextButton(this.m_select_mc.select1_bt,"Select",this.onSelectClick(1)));
                  this.m_select1_bt.visible = this.m_select_mc.visible;
               }
               if(this.m_select_mc.hasOwnProperty("select2_bt"))
               {
                  addWidget(this.m_select2_bt = new FarmAnimatedTextButton(this.m_select_mc.select2_bt,"Select",this.onSelectClick(2)));
                  this.m_select2_bt.visible = this.m_select_mc.visible;
               }
            }
            if(m_window.hasOwnProperty("NoBenefit_mc"))
            {
               addWidget(this.m_AwesomelButton = new FarmAnimatedTextButton(m_window.NoBenefit_mc,"Okay",onClose));
               this.m_AwesomelButton.visible = noOfBonus == 0 && this.manager.hasTimeGatePassed() && !this.m_isBonus && this.m_select_mc.visible == false;
            }
            this.updateCollectionBonuses(noOfBonus);
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_closeButton.visible = this.manager.hasBonusBeenGranted() > 0;
      }
      
      public function onConfirmClick(bonusNo:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_bonusBothMc.visible = false;
            m_closeButton.visible = true;
            m_bonusConfirm_mc.visible = false;
            if(m_window.hasOwnProperty("bonusSingle_mc"))
            {
               m_bonusSingleMc = m_window.bonusSingle_mc as MovieClip;
               m_bonusSingleMc.visible = true;
               if(m_bonusSingleMc.hasOwnProperty("bonus1_mc"))
               {
                  m_bonus1_mc = m_bonusSingleMc["bonus1_mc"] as MovieClip;
                  if(m_bonus1_mc.hasOwnProperty("egg_mc"))
                  {
                     m_egg1_mc = m_bonus1_mc.egg_mc as MovieClip;
                  }
                  if(m_bonus1_mc.hasOwnProperty("name_mc"))
                  {
                     m_name1RewardWindowTf = new FarmTextField(m_bonus1_mc["name_mc"],COLLECTION_BONUS_REWARD1);
                  }
               }
               if(m_bonusSingleMc.hasOwnProperty("bonus2_mc"))
               {
                  m_bonus2_mc = m_bonusSingleMc["bonus2_mc"] as MovieClip;
                  m_bonus2_mc.visible = true;
                  if(m_bonus2_mc.hasOwnProperty("egg_mc"))
                  {
                     m_egg2_mc = m_bonus2_mc.egg_mc as MovieClip;
                  }
                  if(m_bonus2_mc.hasOwnProperty("name_mc"))
                  {
                     m_name2RewardWindowTf = new FarmTextField(m_bonus2_mc.name_mc,COLLECTION_BONUS_REWARD2);
                  }
               }
            }
            if(bonusToGrant == 1)
            {
               m_bonus2_mc.visible = false;
               m_bonus1_mc.visible = true;
               m_egg1_mc.visible = true;
               m_name1RewardWindowTf.visible = true;
               m_egg1_mc.gotoAndPlay(1);
               m_subtitle.text = "You have won the " + COLLECTION_BONUS_REWARD1 + "! Find it in your Giftbox\nand share this news with your friends!";
               m_subtitle.visible = true;
            }
            else
            {
               m_bonus1_mc.visible = false;
               m_bonus2_mc.visible = true;
               m_egg2_mc.visible = true;
               m_name2RewardWindowTf.visible = true;
               m_egg2_mc.gotoAndPlay(1);
               m_subtitle.text = "You have won the " + COLLECTION_BONUS_REWARD2 + "! Find it in your Giftbox\nand share this news with your friends!";
               m_subtitle.visible = true;
            }
            manager.grantBonusItem(bonusToGrant);
            manager.updateMainWindow();
            m_share_mc.visible = true;
            m_closeButton.visible = true;
         };
      }
      
      public function onBackClick(bonusNo:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_bonusConfirm_mc.visible = false;
            m_select_mc.visible = true;
            m_closeButton.visible = false;
            m_AwesomelButton.visible = false;
            m_egg2ConfirmMc.gotoAndStop(1);
            m_egg1ConfirmMc.gotoAndStop(1);
         };
      }
      
      public function onSelectClick(bonusNo:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_select_mc.visible = false;
            m_bonusConfirm_mc.visible = true;
            m_closeButton.visible = false;
            m_AwesomelButton.visible = false;
            if(bonusNo == 1)
            {
               m_egg2ConfirmMc.visible = false;
               m_egg1ConfirmMc.visible = true;
               m_egg1ConfirmMc.gotoAndPlay(1);
               m_bonusConfirm_mc["generic_tf"].text = "You have selected " + COLLECTION_BONUS_REWARD1 + ". Do you want to confirm your choice?";
            }
            else
            {
               m_egg1ConfirmMc.visible = false;
               m_egg2ConfirmMc.visible = true;
               m_egg2ConfirmMc.gotoAndPlay(1);
               m_bonusConfirm_mc["generic_tf"].text = "You have selected " + COLLECTION_BONUS_REWARD2 + ". Do you want to confirm your choice?";
            }
            bonusToGrant = bonusNo;
         };
      }
      
      private function updateCollectionBonuses(noOfBonus:int) : void
      {
         if(m_window.hasOwnProperty("bonusBoth_mc"))
         {
            this.m_bonusBothMc = m_window.bonusBoth_mc as MovieClip;
            this.m_bonusBothMc.visible = true;
            if(this.m_bonusBothMc.hasOwnProperty("bonus1_mc"))
            {
               this.m_bonus1_mc = this.m_bonusBothMc.bonus1_mc as MovieClip;
               this.m_bonus1_mc.visible = true;
               if(this.m_bonus1_mc.hasOwnProperty("egg_mc"))
               {
                  this.m_egg1_mc = this.m_bonus1_mc.egg_mc as MovieClip;
                  this.m_egg1_mc.visible = true;
                  if(this.m_isBonus)
                  {
                     this.m_egg1_mc.gotoAndPlay(1);
                  }
                  else
                  {
                     this.m_egg1_mc.gotoAndPlay(75);
                  }
               }
               if(this.m_bonus1_mc.hasOwnProperty("name_mc"))
               {
                  addWidget(this.m_name1Tf = new FarmTextField(this.m_bonus1_mc["name_mc"],this.COLLECTION_BONUS_REWARD1),true);
               }
            }
            if(this.m_bonusBothMc.hasOwnProperty("bonus2_mc"))
            {
               this.m_bonus2_mc = this.m_bonusBothMc.bonus2_mc as MovieClip;
               this.m_bonus2_mc.visible = true;
               if(this.m_bonus2_mc.hasOwnProperty("egg_mc"))
               {
                  this.m_egg2_mc = this.m_bonus2_mc.egg_mc as MovieClip;
                  this.m_egg2_mc.visible = true;
                  if(this.m_isBonus)
                  {
                     this.m_egg2_mc.gotoAndPlay(1);
                  }
                  else
                  {
                     this.m_egg2_mc.gotoAndPlay(75);
                  }
               }
               if(this.m_bonus2_mc.hasOwnProperty("name_mc"))
               {
                  this.m_name2Tf = new FarmTextField(this.m_bonus2_mc.name_mc,this.COLLECTION_BONUS_REWARD2);
               }
            }
            if(this.m_bonusBothMc.hasOwnProperty("and_mc"))
            {
               this.m_andMc = this.m_bonusBothMc.and_mc as MovieClip;
               this.m_andMc.visible = noOfBonus == 3 || !this.manager.hasTimeGatePassed();
            }
            if(this.m_bonusBothMc.hasOwnProperty("or_mc"))
            {
               this.m_orMc = this.m_bonusBothMc.or_mc as MovieClip;
               this.m_orMc.visible = noOfBonus >= 0 && noOfBonus < 3 && this.manager.hasTimeGatePassed();
            }
         }
         if(m_window.hasOwnProperty("bonusConfirm_mc"))
         {
            this.m_bonusConfirm_mc = m_window.bonusConfirm_mc as MovieClip;
            if(this.m_bonusConfirm_mc.hasOwnProperty("bonus1_mc"))
            {
               this.m_bonus1Confirm_mc = this.m_bonusConfirm_mc.bonus1_mc as MovieClip;
               this.m_bonus1Confirm_mc["name_mc"].visible = false;
               if(this.m_bonus1Confirm_mc.hasOwnProperty("egg_mc"))
               {
                  this.m_egg1ConfirmMc = this.m_bonus1Confirm_mc.egg_mc as MovieClip;
                  this.m_egg1ConfirmMc.visible = false;
               }
            }
            if(this.m_bonusConfirm_mc.hasOwnProperty("bonus2_mc"))
            {
               this.m_bonus2Confirm_mc = this.m_bonusConfirm_mc.bonus2_mc as MovieClip;
               this.m_bonus2Confirm_mc["name_mc"].visible = false;
               if(this.m_bonus2Confirm_mc.hasOwnProperty("egg_mc"))
               {
                  this.m_egg2ConfirmMc = this.m_bonus2Confirm_mc.egg_mc as MovieClip;
                  this.m_egg2ConfirmMc.visible = false;
               }
            }
            if(this.m_bonusConfirm_mc.hasOwnProperty("back_bt"))
            {
               addWidget(this.m_back_bt = new FarmAnimatedTextButton(this.m_bonusConfirm_mc.back_bt,"Cancel",this.onBackClick(noOfBonus)));
            }
            if(this.m_bonusConfirm_mc.hasOwnProperty("confirm_bt"))
            {
               addWidget(this.m_confirm_bt = new FarmAnimatedTextButton(this.m_bonusConfirm_mc.confirm_bt,"Confirm",this.onConfirmClick(noOfBonus)));
            }
            this.m_bonusConfirm_mc.visible = false;
         }
      }
      
      private function onOkayClick(event:Event) : void
      {
         this.close();
      }
      
      private function onShareClick(event:Event) : void
      {
         if(this.m_share_bt)
         {
            this.m_share_bt.enabled = false;
         }
         this.manager.shareBonusFeed(this.bonusToGrant);
      }
      
      private function get manager() : BringBackWinterManager
      {
         return BringBackWinterManager.getInstance(this.m_featureName);
      }
      
      override public function close() : void
      {
         super.close();
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}

