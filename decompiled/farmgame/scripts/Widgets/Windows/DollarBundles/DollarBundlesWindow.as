package Widgets.Windows.DollarBundles
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.DollarBundlesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class DollarBundlesWindow extends FarmWindow
   {
      
      private static var ROTATION_SPEED:int = 0;
      
      private static var ANGLE_MAP:Object = {
         90:0,
         60:315,
         40:270,
         80:225,
         30:180,
         70:135,
         50:90,
         20:45
      };
      
      protected var m_title:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DollarBundles_2015.swf";
      
      private var m_RightPanelReward:MovieClip = new MovieClip();
      
      private var m_smallDialog:MovieClip = new MovieClip();
      
      private var m_Wheel:MovieClip = new MovieClip();
      
      private var m_Slot0:MovieClip = new MovieClip();
      
      private var m_Slot1:MovieClip = new MovieClip();
      
      private var m_Slot2:MovieClip = new MovieClip();
      
      private var m_Slot3:MovieClip = new MovieClip();
      
      private var m_Slot4:MovieClip = new MovieClip();
      
      private var m_Slot5:MovieClip = new MovieClip();
      
      private var m_Slot6:MovieClip = new MovieClip();
      
      private var m_Slot7:MovieClip = new MovieClip();
      
      private var m_WheelShader:MovieClip = new MovieClip();
      
      private var m_Size:MovieClip = new MovieClip();
      
      private var m_Bulb:MovieClip = new MovieClip();
      
      private var m_BulbBorder_start_mc:MovieClip = new MovieClip();
      
      private var m_Scene:MovieClip = new MovieClip();
      
      private var m_WelcomeTitle:MovieClip = new MovieClip();
      
      private var m_CongratsTitle:MovieClip = new MovieClip();
      
      private var m_discount0_mc:MovieClip = new MovieClip();
      
      private var m_discount1_mc:MovieClip = new MovieClip();
      
      private var m_discount2_mc:MovieClip = new MovieClip();
      
      private var m_discount3_mc:MovieClip = new MovieClip();
      
      private var m_discount4_mc:MovieClip = new MovieClip();
      
      private var m_discount5_mc:MovieClip = new MovieClip();
      
      private var m_discount6_mc:MovieClip = new MovieClip();
      
      private var m_discount7_mc:MovieClip = new MovieClip();
      
      private var m_HighLight_mc:MovieClip = new MovieClip();
      
      private var m_CurrentDiscountField:ZwTextField;
      
      private var m_DiscountField1:ZwTextField;
      
      private var m_DiscountField2:ZwTextField;
      
      private var m_DiscountField3:ZwTextField;
      
      private var m_SpinTextField1:ZwTextField;
      
      private var m_SpinTextField2:ZwTextField;
      
      private var m_SpinTextField3:ZwTextField;
      
      private var m_Discount_tf:ZwTextField;
      
      private var m_DialogBody1Text:ZwTextField;
      
      private var m_DialogBody2Text:ZwTextField;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      private var m_WhatisThisButton:FarmButton;
      
      private var m_SpinButton:FarmButton;
      
      private var m_CurrentDiscount:int;
      
      protected var m_item:FarmItem = null;
      
      public function DollarBundlesWindow(path:String = null)
      {
         super(this.ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var discountSlot1:int = 0;
         var discountSlot2:int = 0;
         var discountSlot3:int = 0;
         var itemBox:FarmIcon = null;
         var itemName:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","dollarbundles_Title")));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","dollarbundles_SubTitle")));
         }
         if(m_window.hasOwnProperty("highlight_mc"))
         {
            this.m_HighLight_mc = m_window.highlight_mc;
            this.m_HighLight_mc.visible = true;
            this.m_HighLight_mc.gotoAndPlay(1);
         }
         if(m_window.hasOwnProperty("discount1_tf") && m_window.hasOwnProperty("spinToSee1_tf"))
         {
            discountSlot1 = DollarBundlesManager.getInstance().getDiscountForSlot(1);
            this.m_SpinTextField1 = addWidget(new ZwTextField(m_window.spinToSee1_tf,ZLocUtils.t("Dialogs","dollarbundles_spinToSee"))) as ZwTextField;
            this.m_DiscountField1 = addWidget(new ZwTextField(m_window.discount1_tf,discountSlot1.toString() + "%")) as ZwTextField;
            if(discountSlot1 == 0)
            {
               this.m_DiscountField1.visible = false;
            }
            else
            {
               this.m_SpinTextField1.visible = false;
            }
         }
         if(m_window.hasOwnProperty("discount2_tf") && m_window.hasOwnProperty("spinToSee2_tf"))
         {
            discountSlot2 = DollarBundlesManager.getInstance().getDiscountForSlot(2);
            this.m_SpinTextField2 = addWidget(new ZwTextField(m_window.spinToSee2_tf,ZLocUtils.t("Dialogs","dollarbundles_spinToSee"))) as ZwTextField;
            this.m_DiscountField2 = addWidget(new ZwTextField(m_window.discount2_tf,discountSlot2.toString() + "%")) as ZwTextField;
            if(discountSlot2 == 0)
            {
               this.m_DiscountField2.visible = false;
            }
            else
            {
               this.m_SpinTextField2.visible = false;
            }
         }
         if(m_window.hasOwnProperty("discount3_tf") && m_window.hasOwnProperty("spinToSee3_tf"))
         {
            discountSlot3 = DollarBundlesManager.getInstance().getDiscountForSlot(3);
            this.m_SpinTextField3 = addWidget(new ZwTextField(m_window.spinToSee3_tf,ZLocUtils.t("Dialogs","dollarbundles_spinToSee"))) as ZwTextField;
            this.m_DiscountField3 = addWidget(new ZwTextField(m_window.discount3_tf,discountSlot3.toString() + "%")) as ZwTextField;
            if(discountSlot3 == 0)
            {
               this.m_DiscountField3.visible = false;
            }
            else
            {
               this.m_SpinTextField3.visible = false;
            }
         }
         if(m_window.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_window.timer_tf,"HURRY!\n" + DollarBundlesManager.getInstance().getTimeRemaining() + "\nLEFT"));
         }
         if(m_window.hasOwnProperty("myDiscounts_tf"))
         {
            addWidget(new ZwTextField(m_window.myDiscounts_tf,ZLocUtils.t("Dialogs","dollarbundles_yourDiscounts")));
         }
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            this.m_WhatisThisButton = addWidget(new FarmAnimatedButton(m_window.whatisthis_bt,this.showTutorial)) as FarmButton;
            if(DollarBundlesManager.getInstance().getFinishedSpinCount() == DollarBundlesManager.VAL_DISCOUNT_ARRAY_LENGTH)
            {
               this.m_WhatisThisButton.visible = false;
            }
         }
         if(m_window.hasOwnProperty("spin_bt"))
         {
            this.m_SpinButton = addWidget(new FarmAnimatedButton(m_window.spin_bt,this.startSpin)) as FarmButton;
            (m_window["spin_bt"]["generic_tf"] as TextField).text = "Spins : " + (DollarBundlesManager.VAL_DISCOUNT_ARRAY_LENGTH - DollarBundlesManager.getInstance().getFinishedSpinCount()).toString();
         }
         if(m_window.hasOwnProperty("rightPanelReward_mc"))
         {
            this.m_RightPanelReward = m_window.rightPanelReward_mc;
            this.m_RightPanelReward.visible = true;
            if(this.m_RightPanelReward)
            {
               if(this.m_RightPanelReward.hasOwnProperty("itemTitle_tf"))
               {
                  addWidget(new ZwTextField(this.m_RightPanelReward.itemTitle_tf,DollarBundlesManager.getInstance().getCurrentBundleFriendlyName()));
               }
               if(this.m_RightPanelReward.hasOwnProperty("itemValue_tf"))
               {
                  addWidget(new ZwTextField(this.m_RightPanelReward.itemValue_tf,"$10 value"));
               }
               if(this.m_RightPanelReward.hasOwnProperty("bulbs_mc"))
               {
                  this.m_BulbBorder_start_mc = this.m_RightPanelReward.bulbs_mc;
                  this.m_BulbBorder_start_mc.visible = true;
                  this.m_BulbBorder_start_mc.play();
               }
               if(this.m_RightPanelReward.icon_mc != null)
               {
                  addWidget(new FarmIcon(this.m_RightPanelReward.icon_mc));
               }
               itemBox = getWidget(this.m_RightPanelReward["icon_mc"]) as FarmIcon;
               itemName = DollarBundlesManager.getInstance().getCurrentBundleName();
               this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(Boolean(itemBox) && Boolean(this.m_item))
               {
                  itemBox.loadIcon(this.m_item.icon);
                  itemBox.visible = true;
                  this.m_iconTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs",itemName + "_toolTip"));
                  itemBox.attachTooltip(this.m_iconTooltip);
               }
            }
            if(m_window.hasOwnProperty("smallDialog_mc"))
            {
               this.m_smallDialog = m_window.smallDialog_mc;
               if(!DollarBundlesManager.getInstance().hasFeatureSeen())
               {
                  this.m_smallDialog.visible = true;
                  DollarBundlesManager.getInstance().setFeatureSeenFlag();
               }
               else
               {
                  this.m_smallDialog.visible = false;
               }
               if(this.m_smallDialog)
               {
                  if(this.m_smallDialog.hasOwnProperty("body1_txt"))
                  {
                     this.m_DialogBody1Text = new ZwTextField(this.m_smallDialog.body1_txt,ZLocUtils.t("Dialogs","dollarbundles_welcomeText") + " " + DollarBundlesManager.getInstance().getCurrentBundleFriendlyName() + " Bundle");
                     this.m_DialogBody1Text.visible = true;
                  }
                  if(this.m_smallDialog.hasOwnProperty("body2_txt"))
                  {
                     this.m_DialogBody2Text = new ZwTextField(this.m_smallDialog.body2_txt,ZLocUtils.t("Dialogs","dollarbundles_discountText"));
                     this.m_DialogBody2Text.visible = false;
                  }
                  if(this.m_smallDialog.hasOwnProperty("discount_tf"))
                  {
                     this.m_Discount_tf = new ZwTextField(this.m_smallDialog.discount_tf,"0");
                     this.m_Discount_tf.visible = false;
                  }
                  if(this.m_smallDialog.hasOwnProperty("bulbs_mc"))
                  {
                     this.m_Bulb = this.m_smallDialog.bulbs_mc;
                     this.m_Bulb.visible = true;
                     this.m_Bulb.play();
                  }
                  if(this.m_smallDialog.hasOwnProperty("scene_mc"))
                  {
                     this.m_Scene = this.m_smallDialog.scene_mc;
                     this.m_Scene.visible = true;
                  }
                  if(this.m_smallDialog.hasOwnProperty("titleWelcome_mc"))
                  {
                     this.m_WelcomeTitle = this.m_smallDialog.titleWelcome_mc;
                     this.m_WelcomeTitle.visible = true;
                  }
                  if(this.m_smallDialog.hasOwnProperty("titleCongrats_mc"))
                  {
                     this.m_CongratsTitle = this.m_smallDialog.titleCongrats_mc;
                     this.m_CongratsTitle.visible = false;
                  }
                  if(this.m_smallDialog.hasOwnProperty("accept_bt"))
                  {
                     addWidget(new FarmAnimatedButton(this.m_smallDialog.accept_bt,this.okayCallBack));
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("wheel_mc"))
         {
            this.m_Wheel = m_window.wheel_mc;
            this.m_Wheel.visible = true;
            if(this.m_Wheel)
            {
               if(this.m_Wheel.hasOwnProperty("slot_0_mc"))
               {
                  this.m_Slot0 = this.m_Wheel.slot_0_mc;
                  this.m_Slot0.visible = true;
                  if(this.m_Slot0)
                  {
                     this.m_discount0_mc = this.m_Slot0.discount0_mc as MovieClip;
                     this.m_discount0_mc.visible = true;
                     if(this.m_discount0_mc)
                     {
                        if(this.m_discount0_mc.hasOwnProperty("percent0_tf"))
                        {
                           addWidget(new ZwTextField(this.m_discount0_mc.percent0_tf,"90%"));
                        }
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_1_mc"))
               {
                  this.m_Slot1 = this.m_Wheel.slot_1_mc;
                  this.m_Slot1.visible = true;
                  if(this.m_Slot1)
                  {
                     this.m_discount1_mc = this.m_Slot1.discount1_mc as MovieClip;
                     this.m_discount1_mc.visible = true;
                     if(this.m_discount1_mc.hasOwnProperty("percent1_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount1_mc.percent1_tf,"60%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_2_mc"))
               {
                  this.m_Slot2 = this.m_Wheel.slot_2_mc;
                  this.m_Slot2.visible = true;
                  if(this.m_Slot2)
                  {
                     this.m_discount2_mc = this.m_Slot2.discount2_mc as MovieClip;
                     this.m_discount2_mc.visible = true;
                     if(this.m_discount2_mc.hasOwnProperty("percent2_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount2_mc.percent2_tf,"40%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_3_mc"))
               {
                  this.m_Slot3 = this.m_Wheel.slot_3_mc;
                  this.m_Slot3.visible = true;
                  if(this.m_Slot3)
                  {
                     this.m_discount3_mc = this.m_Slot3.discount3_mc as MovieClip;
                     this.m_discount3_mc.visible = true;
                     if(this.m_discount3_mc.hasOwnProperty("percent3_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount3_mc.percent3_tf,"80%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_4_mc"))
               {
                  this.m_Slot4 = this.m_Wheel.slot_4_mc;
                  this.m_Slot4.visible = true;
                  if(this.m_Slot4)
                  {
                     this.m_discount4_mc = this.m_Slot4.discount4_mc as MovieClip;
                     this.m_discount4_mc.visible = true;
                     if(this.m_discount4_mc.hasOwnProperty("percent4_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount4_mc.percent4_tf,"30%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_5_mc"))
               {
                  this.m_Slot5 = this.m_Wheel.slot_5_mc;
                  this.m_Slot5.visible = true;
                  if(this.m_Slot5)
                  {
                     this.m_discount5_mc = this.m_Slot5.discount5_mc as MovieClip;
                     this.m_discount5_mc.visible = true;
                     if(this.m_discount5_mc.hasOwnProperty("percent5_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount5_mc.percent5_tf,"70%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_6_mc"))
               {
                  this.m_Slot6 = this.m_Wheel.slot_6_mc;
                  this.m_Slot6.visible = true;
                  if(this.m_Slot6)
                  {
                     this.m_discount6_mc = this.m_Slot6.discount6_mc as MovieClip;
                     this.m_discount6_mc.visible = true;
                     if(this.m_discount6_mc.hasOwnProperty("percent6_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount6_mc.percent6_tf,"50%"));
                     }
                  }
               }
               if(this.m_Wheel.hasOwnProperty("slot_7_mc"))
               {
                  this.m_Slot7 = this.m_Wheel.slot_7_mc;
                  this.m_Slot7.visible = true;
                  if(this.m_Slot7)
                  {
                     this.m_discount7_mc = this.m_Slot7.discount7_mc as MovieClip;
                     this.m_discount7_mc.visible = true;
                     if(this.m_discount7_mc.hasOwnProperty("percent7_tf"))
                     {
                        addWidget(new ZwTextField(this.m_discount7_mc.percent7_tf,"20%"));
                     }
                  }
               }
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_Size = m_window.size_mc;
            this.m_Size.visible = true;
         }
         if(m_window.hasOwnProperty("wheelShader_mc"))
         {
            this.m_WheelShader = m_window.wheelShader_mc;
            this.m_WheelShader.visible = true;
         }
         FarmStatsManager.count("Superbundle","Action","MainUI","view",DollarBundlesManager.getInstance().getCurrentBundleName(),"");
      }
      
      public function showTutorial(event:Event) : void
      {
         this.m_smallDialog.visible = true;
         this.m_DialogBody2Text.visible = false;
         this.m_Discount_tf.visible = false;
         this.m_DialogBody1Text.visible = true;
         this.m_WelcomeTitle.visible = true;
         this.m_CongratsTitle.visible = false;
      }
      
      override public function close() : void
      {
         super.close();
         FarmStatsManager.count("Superbundle","Action","MainUI","close","","");
      }
      
      public function okayCallBack(event:Event) : void
      {
         this.m_smallDialog.visible = false;
         if(DollarBundlesManager.getInstance().getFinishedSpinCount() == DollarBundlesManager.VAL_DISCOUNT_ARRAY_LENGTH)
         {
            this.close();
            DollarBundlesManager.getInstance().openDollarBundlesUI();
         }
      }
      
      public function startSpin(event:Event) : void
      {
         m_closeButton.enabled = false;
         this.m_SpinButton.enabled = false;
         addEventListener(Event.ENTER_FRAME,this.spinTheWheel);
         ROTATION_SPEED = 30;
         DollarBundlesManager.getInstance().getBundleDiscount(this.StopSpinning);
      }
      
      private function StopSpinning(discount:int) : void
      {
         var discountStr:String = null;
         var randomRotation:int = 0;
         var version:Number = NaN;
         if(this == UI.getCurrentPopup())
         {
            this.m_CurrentDiscount = discount;
            ROTATION_SPEED = 0;
            this.m_Wheel.rotation = ROTATION_SPEED;
            discountStr = discount.toString();
            randomRotation = 360 * this.randomRange(5,12) + int(ANGLE_MAP[discountStr]);
            TweenMax.to(this.m_Wheel,5,{
               "rotation":randomRotation,
               "delay":0,
               "onComplete":this.displayDialogAfterSpin
            });
            version = DollarBundlesManager.getInstance().getCurrentVersion();
            FarmStatsManager.count("Superbundle","Action","MainUI","spin",discountStr);
         }
      }
      
      public function spinTheWheel(event:Event) : void
      {
         this.m_Wheel.rotation += ROTATION_SPEED;
      }
      
      public function displayDialogAfterSpin() : void
      {
         var timer:Timer = new Timer(2000,1);
         timer.addEventListener(TimerEvent.TIMER,this.updateDiscount);
         timer.start();
      }
      
      public function updateDiscount(event:TimerEvent) : void
      {
         m_closeButton.enabled = true;
         this.m_SpinButton.enabled = true;
         this.setCurrentDiscountField();
         this.m_CurrentDiscountField.text = this.m_CurrentDiscount.toString() + "%";
         this.m_CurrentDiscountField.visible = true;
         var spinFinishedCount:int = DollarBundlesManager.getInstance().getFinishedSpinCount();
         DollarBundlesManager.getInstance().setDiscountsForSpin(spinFinishedCount,this.m_CurrentDiscount);
         spinFinishedCount += 1;
         DollarBundlesManager.getInstance().saveFeatureOptionsKey(DollarBundlesManager.FINISHED_SPIN_COUNT,spinFinishedCount);
         var maxDiscount:int = DollarBundlesManager.getInstance().getMaxDiscount();
         (m_window["spin_bt"]["generic_tf"] as TextField).text = "Spins : " + (DollarBundlesManager.VAL_DISCOUNT_ARRAY_LENGTH - DollarBundlesManager.getInstance().getFinishedSpinCount()).toString();
         this.m_smallDialog.visible = true;
         this.m_DialogBody2Text.visible = true;
         this.m_Discount_tf.text = this.m_CurrentDiscount.toString() + "%";
         this.m_Discount_tf.visible = true;
         this.m_DialogBody1Text.visible = false;
         this.m_WelcomeTitle.visible = false;
         this.m_CongratsTitle.visible = true;
      }
      
      public function setCurrentDiscountField() : void
      {
         var numOfSpinFinished:int = DollarBundlesManager.getInstance().getFinishedSpinCount();
         switch(numOfSpinFinished)
         {
            case 1:
               this.m_CurrentDiscountField = this.m_DiscountField2;
               this.m_SpinTextField2.visible = false;
               break;
            case 2:
               this.m_CurrentDiscountField = this.m_DiscountField3;
               this.m_SpinTextField3.visible = false;
               break;
            case 0:
            default:
               this.m_CurrentDiscountField = this.m_DiscountField1;
               this.m_SpinTextField1.visible = false;
         }
      }
      
      public function randomRange(minNum:Number, maxNum:Number) : Number
      {
         return Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
      }
   }
}

