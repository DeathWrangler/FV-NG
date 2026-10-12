package Widgets.Slots
{
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class BobsBerryQuestLevelSlot extends ZwSlotFrame
   {
      
      private var m_owner:BobBerryFarmWindow;
      
      protected var m_data:Object;
      
      private var m_rewardcount_tf:FarmTextField;
      
      private var m_playquest_bt:FarmAnimatedButton;
      
      private var m_earn_tf:FarmTextField;
      
      private var m_featurename:String;
      
      public function BobsBerryQuestLevelSlot(element:DisplayObject, owner:BobBerryFarmWindow, featureName:String)
      {
         super(element);
         this.m_owner = owner;
         this.m_featurename = featureName;
         if(m_element.hasOwnProperty("rewardcount_tf"))
         {
            this.m_rewardcount_tf = addWidget(new FarmTextField(m_element.rewardcount_tf as TextField,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("playquest_bt"))
         {
            this.m_playquest_bt = addWidget(new FarmAnimatedButton(m_element.playquest_bt as MovieClip,this.setDifficultyAndDisplayQuests),true) as FarmAnimatedButton;
         }
         if(m_element.hasOwnProperty("earn_tf"))
         {
            this.m_earn_tf = addWidget(new FarmTextField(m_element.earn_tf as TextField,"Earn"),true) as FarmTextField;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_rewardcount_tf.text = this.m_data.rewardcount_tf;
         this.m_rewardcount_tf.visible = true;
         this.m_playquest_bt.visible = true;
         this.m_earn_tf.visible = true;
      }
      
      override public function release() : void
      {
         this.m_owner = null;
         this.m_data = null;
         this.m_rewardcount_tf = null;
         this.m_playquest_bt = null;
         this.m_earn_tf = null;
         super.release();
      }
      
      public function setDifficultyAndDisplayQuests(event:Event = null) : void
      {
         var isQuestActive:Boolean = BobBerryManager.getInstance(this.m_featurename).isQuestsActive();
         var isDifficultySet:Boolean = BobBerryManager.getInstance(this.m_featurename).isDifficultySet();
         this.m_owner.pause();
         if(!isQuestActive && !isDifficultySet)
         {
            BobBerryManager.getInstance(this.m_featurename).startQuest(this.m_data.levelType,this.unPauseAndRefreshMainWindow);
         }
         else
         {
            BobBerryManager.getInstance(this.m_featurename).changeDifficulty(this.m_data.levelType,this.unPauseAndRefreshMainWindow);
         }
         this.m_owner.m_subtitleTf.visible = false;
      }
      
      public function unPauseAndRefreshMainWindow() : void
      {
         this.m_owner.unpause();
         this.m_owner.refreshMainUI();
      }
   }
}

