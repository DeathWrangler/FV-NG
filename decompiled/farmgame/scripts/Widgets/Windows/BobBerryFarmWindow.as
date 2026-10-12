package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BobBerryExpiryFrame;
   import Widgets.Frames.BobBerryLimitFrame;
   import Widgets.Frames.BobBerryRewardFrame;
   import Widgets.Frames.BobsBerryQuestLevelContainterFrame;
   import Widgets.Frames.BobsBerryQuestTaskContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class BobBerryFarmWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      public static const NUM_OF_SLOTS:int = 3;
      
      public var m_select_quest_frame:BobsBerryQuestLevelContainterFrame;
      
      public var m_task_frame:BobsBerryQuestTaskContainerFrame;
      
      public var m_marketButton:FarmAnimatedButton;
      
      private var m_featureName:String = null;
      
      private var m_timerFrame:ZwFrame;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_berryLimitFrame:BobBerryLimitFrame;
      
      private var m_expiryFrame:BobBerryExpiryFrame;
      
      private var m_rewardFrame:BobBerryRewardFrame;
      
      private var m_titleTf:FarmTextField;
      
      public var m_subtitleTf:FarmTextField;
      
      public function BobBerryFarmWindow(dialogURL:String, featureName:String)
      {
         super(featureName,dialogURL,NUM_TUTORIAL_SCENES);
         this.m_featureName = featureName;
         if(BobBerryManager.getInstance(this.m_featureName).isQuestsActive())
         {
            BobBerryManager.getInstance(this.m_featureName).setFeatureSeenTimeStamp();
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.m_titleTf = addWidget(new FarmTextField(m_window["title_tf"],ZLocUtils.t("Dialogs",this.m_featureName + "_Title")),true) as FarmTextField;
               this.m_titleTf.visible = true;
               if(m_window.hasOwnProperty("subtitle_tf"))
               {
                  this.m_subtitleTf = new FarmTextField(m_window["subtitle_tf"],ZLocUtils.t("Dialogs",this.m_featureName + "_Subtitle"),true) as FarmTextField;
                  this.m_subtitleTf.visible = true;
               }
            }
            if(m_window.hasOwnProperty("market_bt"))
            {
               this.m_marketButton = addWidget(new FarmAnimatedButton(m_window["market_bt"],this.openBobsMarket),true) as FarmAnimatedButton;
            }
            if(m_window.hasOwnProperty("count_mc") && m_window.count_mc.count_tf != null)
            {
               m_window.count_mc.count_tf.text = "x" + BobBerryManager.getInstance(this.m_featureName).getCurrentCurrencyCount();
               m_window.count_mc.visible = true;
               if(m_window.hasOwnProperty("capacity_tf"))
               {
                  m_window.capacity_tf.visible = true;
               }
            }
            if(m_window.hasOwnProperty("whatisthis_mc"))
            {
               addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onHowDoesThisWorkClick));
            }
            if(m_window.hasOwnProperty("questclick_mc"))
            {
               this.m_task_frame = new BobsBerryQuestTaskContainerFrame(m_window.questclick_mc,this,this.m_featureName);
            }
            if(m_window.hasOwnProperty("selectquest_mc"))
            {
               this.m_select_quest_frame = new BobsBerryQuestLevelContainterFrame(m_window.selectquest_mc,this,this.m_featureName);
               if(this.m_select_quest_frame)
               {
                  if(m_window.selectquest_mc.hasOwnProperty("title2_tf"))
                  {
                     addWidget(new FarmTextField(m_window.selectquest_mc.title2_tf,"Play And Earn Berries!"),true);
                  }
               }
            }
            if(m_window.hasOwnProperty("timeleft_mc") && Boolean(m_window["timeleft_mc"].hasOwnProperty("time_tf")))
            {
               addWidget(this.m_timerFrame = new ZwFrame(m_window.timeleft_mc));
               if(this.m_timerFrame)
               {
                  this.m_timerTextField = new ZwTextField(m_window.timeleft_mc.time_tf,this.timeRemaining());
                  this.m_timerTextField.visible = true;
                  m_window.timeleft_mc.left_tf.visible = true;
               }
            }
            if(m_window.hasOwnProperty("noberries_mc"))
            {
               this.m_berryLimitFrame = new BobBerryLimitFrame(this,m_window.noberries_mc,this.m_featureName);
            }
            if(m_window.hasOwnProperty("expiry_mc"))
            {
               this.m_expiryFrame = new BobBerryExpiryFrame(this,m_window.expiry_mc,this.m_featureName);
            }
            if(m_window.hasOwnProperty("complete_mc"))
            {
               this.m_rewardFrame = new BobBerryRewardFrame(m_window.complete_mc,this,this.m_featureName);
            }
            this.refreshMainUI();
         }
      }
      
      public function openBobsMarket(ev:Event = null) : void
      {
         onClose(ev);
         UI.displayMarketDialog("unknown","bobsFarm");
      }
      
      public function showExpiryFrame() : void
      {
         this.m_select_quest_frame.visible = false;
         this.m_task_frame.visible = false;
         this.m_berryLimitFrame.visible = false;
         this.m_expiryFrame.visible = true;
         this.m_rewardFrame.visible = false;
      }
      
      public function onRedeemClick(ev:Event = null) : void
      {
         ev.currentTarget.removeEventListener(ev.type,this.onRedeemClick);
         this.openBobsMarket();
      }
      
      public function showTaskFrame() : void
      {
         this.m_select_quest_frame.visible = false;
         this.m_task_frame.visible = true;
         this.m_berryLimitFrame.visible = false;
         this.m_expiryFrame.visible = false;
         this.m_rewardFrame.visible = false;
      }
      
      public function showLevelFrame() : void
      {
         this.m_select_quest_frame.visible = true;
         this.m_task_frame.visible = false;
         this.m_berryLimitFrame.visible = false;
         this.m_expiryFrame.visible = false;
         this.m_rewardFrame.visible = false;
      }
      
      public function showLimitReachedFrame() : void
      {
         this.m_select_quest_frame.visible = false;
         this.m_task_frame.visible = false;
         this.m_berryLimitFrame.visible = true;
         this.m_expiryFrame.visible = false;
         this.m_rewardFrame.visible = false;
      }
      
      public function showRewardFrame() : void
      {
         this.m_select_quest_frame.visible = false;
         this.m_task_frame.visible = false;
         this.m_berryLimitFrame.visible = false;
         this.m_expiryFrame.visible = false;
         this.m_rewardFrame.visible = true;
      }
      
      public function refreshMainUI() : void
      {
         m_window.count_mc.count_tf.text = "x" + BobBerryManager.getInstance(this.m_featureName).getCurrentCurrencyCount();
         if(BobBerryManager.getInstance(this.m_featureName).isExpired())
         {
            this.showExpiryFrame();
         }
         else if(BobBerryManager.getInstance(this.m_featureName).shouldShowReward())
         {
            this.m_rewardFrame.refresh();
            this.showRewardFrame();
         }
         else if(BobBerryManager.getInstance(this.m_featureName).isQuestsActive() && BobBerryManager.getInstance(this.m_featureName).isDifficultySet())
         {
            this.m_task_frame.refresh();
            this.showTaskFrame();
         }
         else if(BobBerryManager.getInstance(this.m_featureName).hasReachedCurrencyLimit())
         {
            this.showLimitReachedFrame();
         }
         else
         {
            this.m_select_quest_frame.refresh();
            this.showLevelFrame();
         }
      }
      
      private function timeRemaining() : String
      {
         return BobBerryManager.getInstance(this.m_featureName).getTimeRemaining();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      override protected function release() : void
      {
         this.m_select_quest_frame = null;
         this.m_task_frame = null;
         this.m_berryLimitFrame = null;
         this.m_expiryFrame = null;
         this.m_rewardFrame = null;
         this.m_marketButton = null;
         this.m_timerFrame = null;
         this.m_timerTextField = null;
         this.m_titleTf = null;
         this.m_subtitleTf = null;
         super.release();
      }
   }
}

