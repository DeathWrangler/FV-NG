package Widgets.Windows.Quests
{
   import Classes.Quest.FarmQuest;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Init.QuestSettingsInit;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class QuestBonusStagesFute extends FarmWindow
   {
      
      private const OKAY_BT:String = "okay_bt";
      
      private var m_okayBT:MovieClip;
      
      private var s_questName:String;
      
      public function QuestBonusStagesFute(windowAssetRelUrl:String, questName:String, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         this.s_questName = questName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.OKAY_BT))
         {
            this.m_okayBT = m_window[this.OKAY_BT];
            this.m_okayBT.addEventListener(MouseEvent.CLICK,this.onOkayClick);
            this.m_okayBT.visible = true;
         }
      }
      
      private function onOkayClick(evt:MouseEvent = null) : void
      {
         super.onClose(evt);
         Global.player.setSeenFlag("QuestBonusFtue" + this.s_questName);
         var quest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(this.s_questName) as FarmQuest;
         if(Boolean(quest) && quest.name == this.s_questName)
         {
            quest.showProgress();
         }
      }
   }
}

