package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.GenericQuestTaskSlot;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   
   public class GenericQuestWithRewardWindow extends FarmWindowWithTutorial
   {
      
      public static const PREVIEWWIDTH:Number = 125;
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      private var m_questName:String;
      
      private var m_quest:FarmQuest = FarmQuestManager.getInstance().getActiveQuestByName(this.m_questName);
      
      private var m_whatisthisBtn:FarmAnimatedButton;
      
      private var m_completeButton:FarmAnimatedCashButton;
      
      public function GenericQuestWithRewardWindow(dialogAsset:String, questName:String)
      {
         this.m_questName = questName;
         super(this.m_quest.chain,dialogAsset,NUM_TUTORIAL_SCENES);
         QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
      }
      
      public static function showWindow(questName:String, assetPath:String = "") : void
      {
         var assetUrl:String = assetPath;
         if(assetPath == "")
         {
            assetUrl = Global.farmGameSettingsManager.getAttribute(FarmQuestManager.getInstance().getActiveQuestByName(questName).chain + "_ui");
         }
         UI.displayPopup(new GenericQuestWithRewardWindow(assetUrl,questName));
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.whatisthis_mc)
         {
            addWidget(this.m_whatisthisBtn = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
         }
         if(m_window.header_tf != null)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs",this.m_quest.chain + "Title")));
         }
         if(m_window.subHeader_tf != null)
         {
            addWidget(new ZwTextField(m_window.subHeader_tf,ZLocUtils.t("Dialogs",this.m_quest.chain + "Subtitle")));
         }
         if(m_window.timer_tf != null)
         {
            addWidget(new ZwTextField(m_window.timer_tf,this.getExpiryDateText()));
         }
         if(m_window.complete_bt != null)
         {
            addWidget(this.m_completeButton = new FarmAnimatedCashButton(m_window.complete_bt,ZLocUtils.t("Dialogs",this.m_quest.chain + "CompleteButton"),this.m_quest.getSkipQuestCashCost().toString(),this.completeAllCallback));
         }
         this.initTaskSlots();
         this.initRewards();
      }
      
      private function onQuestComplete(event:QuestEvent) : void
      {
         if(event.quest.name == this.m_questName)
         {
            this.close();
         }
      }
      
      private function completeAllCallback(event:Event) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_quest.chain + "CompleteConfirmPopup",{"cashQuantity":this.m_quest.getSkipQuestCashCost()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteAllPopupClose,"",true);
      }
      
      private function onConfirmCompleteAllPopupClose(event:GenericPopupEvent) : void
      {
         var cash:int = 0;
         if(event.button == GenericPopup.YES)
         {
            cash = this.m_quest.getSkipQuestCashCost();
            if(Global.player.canBuyCash(cash))
            {
               this.m_completeButton.enabled = false;
               this.close();
               this.m_quest.skipQuest();
            }
         }
      }
      
      private function getExpiryDateText() : String
      {
         var secondsLeft:int = this.m_quest.timeRemaining;
         return FarmGameUtil.toFriendlyTime(secondsLeft);
      }
      
      private function initTaskSlots() : void
      {
         var elementName:String = null;
         var task:FarmTask = null;
         var i:int = 0;
         for each(task in this.m_quest.farmTasks)
         {
            elementName = "cell" + i + "_mc";
            if(!m_window[elementName])
            {
               break;
            }
            addWidget(new GenericQuestTaskSlot(m_window[elementName],this,task));
            i++;
         }
      }
      
      private function initRewards() : void
      {
         var farmItem:FarmItem = null;
         var reward:Object = null;
         var prizeFrame:ZwFrame = null;
         var itemPreview:ObjectPreviewFrame = null;
         for each(reward in this.m_quest.farmRewards)
         {
            if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
               if(this.m_quest.farmRewards.length == 1 && !(farmItem is ConsumableItem))
               {
                  addWidget(prizeFrame = new ZwFrame(m_window.prize_mc));
                  prizeFrame.addWidget(new ZwFrame(m_window.prize_mc.reward_mc));
                  prizeFrame.addWidget(new ZwTextField(m_window.prize_mc.reward_mc.win_tf,ZLocUtils.t("Dialogs",this.m_quest.chain + "WinText")));
                  prizeFrame.addWidget(new ZwTextField(m_window.prize_mc.reward_mc.prize_tf,ZLocUtils.t("Dialogs",this.m_quest.chain + "PrizeText")));
                  itemPreview = new ObjectPreviewFrame(m_window.prize_mc.reward_mc.icon_mc,farmItem,null,null,[PREVIEWWIDTH]);
                  itemPreview.y += PREVIEWWIDTH / 2;
                  addWidget(itemPreview);
               }
               else
               {
                  addWidget(new FarmIcon(m_window.prize_mc.reward_mc.icon_mc,farmItem.icon));
               }
            }
         }
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function refreshData() : void
      {
         if(this.m_completeButton)
         {
            this.m_completeButton.setAmountText(this.m_quest.getSkipQuestCashCost().toString());
         }
      }
      
      override protected function release() : void
      {
         this.m_whatisthisBtn = null;
         this.m_completeButton = null;
         QuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,this.onQuestComplete);
         super.release();
      }
   }
}

