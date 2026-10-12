package Widgets.Slots.DuckPond
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TChooseFriendSetReward;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.DuckPond.DuckGameWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class DuckGameRewardSlot extends ZwSlotFrame
   {
      
      private var m_duckGameWindow:DuckGameWindow;
      
      private var m_expiredText:ZwTextField;
      
      private var m_prizeOn:ZwWidget;
      
      private var m_spacer:ZwWidget;
      
      private var m_choose:FarmAnimatedTextButton;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      private var m_toolTip:FarmTextTooltip = new FarmTextTooltip();
      
      private var m_farmItem:FarmItem;
      
      private var m_chooseButtonState:Boolean = true;
      
      public function DuckGameRewardSlot(element:DisplayObject, duckGameWindow:DuckGameWindow)
      {
         this.m_duckGameWindow = duckGameWindow;
         super(element);
      }
      
      override public function populate(rewardObject:Object) : void
      {
         if(this.m_objectPreviewFrame)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_expiredText)
         {
            removeWidget(this.m_expiredText);
            this.m_expiredText = null;
         }
         if(this.m_prizeOn)
         {
            removeWidget(this.m_prizeOn);
            this.m_prizeOn = null;
         }
         if(this.m_spacer)
         {
            removeWidget(this.m_spacer);
            this.m_spacer = null;
         }
         if(this.m_choose)
         {
            removeWidget(this.m_choose);
            this.m_choose = null;
         }
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardObject.itemCode);
         if(Boolean(this.m_farmItem) && (this.m_duckGameWindow.rewardCode == "" || this.m_duckGameWindow.rewardCode == this.m_farmItem.code))
         {
            this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.loader_mc,this.m_farmItem,null,[2]);
            addWidget(this.m_objectPreviewFrame);
            this.m_expiredText = new ZwTextField(m_element.expired_tf,ZLocUtils.t("Dialogs","DuckGame_Expired"));
            addWidget(this.m_expiredText,false);
            this.m_prizeOn = new ZwWidget(m_element.prizeOn_mc);
            addWidget(this.m_prizeOn,false);
            this.m_spacer = new ZwWidget(m_element.spacer_mc);
            addWidget(this.m_spacer,false);
            this.m_choose = new FarmAnimatedTextButton(m_element.choose_bt,ZLocUtils.t("Dialogs","DuckGame_Choose"),this.onChooseClick);
            addWidget(this.m_choose,false);
            this.m_choose.enabled = this.m_chooseButtonState;
            detachTooltip();
            attachTooltip(this.m_toolTip);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_duckGameWindow = null;
         this.m_expiredText = null;
         this.m_prizeOn = null;
         this.m_spacer = null;
         this.m_choose = null;
         this.m_objectPreviewFrame = null;
         this.m_toolTip = null;
         this.m_farmItem = null;
      }
      
      public function update() : void
      {
         var index:String = null;
         var daysLeft:Number = NaN;
         var finishDays:int = 0;
         var timeRemaining:Number = NaN;
         var timeLeft:String = null;
         var Hours:int = 0;
         var Minutes:int = 0;
         var Seconds:int = 0;
         if(this.m_objectPreviewFrame)
         {
            index = name.replace("slot_","");
            index = index.replace("_mc","");
            daysLeft = this.m_duckGameWindow.daysLeft - Number(index);
            if(daysLeft < 0)
            {
               this.m_objectPreviewFrame.alpha = 0.25;
               this.m_expiredText.visible = true;
               this.m_prizeOn.visible = false;
               this.m_spacer.visible = false;
               finishDays = 7 - Number(index);
               if(finishDays == 1)
               {
                  this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipExpired",{
                     "quantity":finishDays,
                     "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                  }));
               }
               else
               {
                  this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipExpiredPlural",{
                     "quantity":finishDays,
                     "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                  }));
               }
            }
            else
            {
               this.m_objectPreviewFrame.alpha = 1;
               this.m_expiredText.visible = false;
               this.m_prizeOn.visible = true;
               if(this.m_duckGameWindow.friendsRequired != 0)
               {
                  this.m_spacer.visible = true;
               }
               else
               {
                  this.m_spacer.visible = false;
               }
               if(this.m_duckGameWindow.friendsRequired == 0)
               {
                  this.m_toolTip.setText(ZLocUtils.tk_pk_asTitle(this.m_farmItem.friendlyName));
                  if(this.m_duckGameWindow.rewardCode == "")
                  {
                     this.m_choose.visible = true;
                  }
                  else
                  {
                     this.m_choose.visible = false;
                  }
               }
               else
               {
                  timeRemaining = daysLeft * FarmGameUtil.NUM_SECS_IN_DAY;
                  Hours = 0;
                  Minutes = 0;
                  Seconds = 0;
                  if(daysLeft < 1)
                  {
                     Seconds = int(timeRemaining);
                     if(Seconds > 60)
                     {
                        Minutes = int(timeRemaining) / 60;
                        Seconds = int(timeRemaining) % 60;
                     }
                     if(Minutes > 60)
                     {
                        Hours = Minutes / 60;
                        Minutes %= 60;
                     }
                     if(Hours > 0 && Minutes > 0)
                     {
                        this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipTimeHoursMins",{
                           "hourNum":Hours,
                           "minuteNum":Minutes,
                           "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                        }));
                     }
                     else if(Hours > 0)
                     {
                        this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipTimeHours",{
                           "hourNum":Hours,
                           "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                        }));
                     }
                     else if(Minutes > 0 && Seconds > 0)
                     {
                        this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipTimeMinsSecs",{
                           "minuteNum":Minutes,
                           "secondNum":Seconds,
                           "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                        }));
                     }
                     else if(Minutes > 0)
                     {
                        this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipTimeMins",{
                           "minuteNum":Minutes,
                           "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                        }));
                     }
                     else
                     {
                        this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipTimeSecs",{
                           "secondNum":Seconds,
                           "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                        }));
                     }
                  }
                  else if(daysLeft < 2)
                  {
                     this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipDay",{"item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)}));
                  }
                  else
                  {
                     this.m_toolTip.setText(ZLocUtils.t("Dialogs","DuckGame_ToolTipDays",{
                        "quantity":int(daysLeft),
                        "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName)
                     }));
                  }
               }
            }
         }
      }
      
      private function onChooseClick(event:MouseEvent) : void
      {
         var delegateCallback:Function = null;
         var index:String = name.replace("slot_","");
         index = index.replace("_mc","");
         var daysLeft:Number = this.m_duckGameWindow.daysLeft - Number(index);
         if(this.m_duckGameWindow.friendsRequired == 0 && this.m_duckGameWindow.rewardCode == "" && daysLeft >= 0)
         {
            delegateCallback = function(result:Object):void
            {
               m_duckGameWindow.setDuckChosen(m_farmItem.code,result);
            };
            TransactionManager.addTransaction(new TChooseFriendSetReward(this.m_duckGameWindow.itemFeatureFriendSet,this.m_duckGameWindow.worldId,this.m_farmItem.code,delegateCallback),true);
            this.m_duckGameWindow.buttonsEnabled = false;
            FarmStatsManager.count("duck_pond_feature","duckling_state_changed","choose_reward",this.m_farmItem.code);
         }
      }
      
      public function set chooseEnabled(newState:Boolean) : void
      {
         this.m_choose.enabled = newState;
         this.m_chooseButtonState = newState;
      }
   }
}

