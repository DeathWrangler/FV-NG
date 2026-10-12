package Classes.consumables
{
   import Classes.FarmGameObject;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CHaitiBiscuit extends CBuff
   {
      
      private const SPARKLE_TIME:int = 2500;
      
      private var m_timer:Timer = null;
      
      public function CHaitiBiscuit(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         Global.player.avatar.centerOn();
         FarmStatsManager.count("CHaitiBiscuit","onUse",this.m_item.name);
         if(this.m_timer == null)
         {
            Global.player.avatar.startOverlay(FarmGameObject.SPARKLE_URL);
            this.m_timer = new Timer(this.SPARKLE_TIME,1);
            this.m_timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            this.m_timer.start();
         }
         Global.hud.iconQueue.removeIconByName("HaitiBiscuit");
      }
      
      private function onTimerComplete(event:TimerEvent) : void
      {
         var userMessage:String = null;
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            this.m_timer = null;
            Global.player.avatar.stopOverlay();
            super.onUse();
            userMessage = ZLocUtils.t("Dialogs","AvatarSpeed_" + this.m_item.name);
            if(Boolean(userMessage) && userMessage != "")
            {
               UI.displayMessageWithHtml(userMessage);
            }
         }
      }
   }
}

