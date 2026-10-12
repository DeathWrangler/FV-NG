package MyLife.Assets.Avatar.AvatarActions
{
   import MyLife.Events.AvatarActionEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class AvatarAction extends EventDispatcher
   {
      
      public static const INTERRUPTION_DO_LATER:Number = 0;
      
      public static const INTERRUPTION_DO_NEVER:Number = 1;
      
      public static const INTERRUPTION_DO_NOW:Number = 2;
      
      protected var avatarClip:MovieClip;
      
      protected var characterClip:MovieClip;
      
      protected var actionParams:Object;
      
      protected var actionId:String;
      
      protected var isWaiting:Boolean;
      
      protected var interruptionType:Number;
      
      protected var m_isPlaying:Boolean;
      
      public function AvatarAction(param1:String, param2:MovieClip, param3:Object, param4:Number = 2, param5:Boolean = false)
      {
         super();
         this.actionId = param1;
         this.actionParams = param3;
         this.avatarClip = param2;
         this.characterClip = param2.parentCharacter;
         this.interruptionType = param4;
         this.isWaiting = param5;
      }
      
      public function getActionParams() : Object
      {
         return this.actionParams;
      }
      
      public function isAvatarWaiting() : Boolean
      {
         return this.isWaiting;
      }
      
      public function getInterruptionType() : Number
      {
         return this.interruptionType;
      }
      
      public function start() : void
      {
         this.avatarClip.addEventListener(Event.ENTER_FRAME,this.updateAction);
      }
      
      public function pause() : void
      {
         this.stop();
      }
      
      public function resume() : void
      {
         this.start();
      }
      
      public function stop() : void
      {
         if(this.avatarClip != null)
         {
            this.avatarClip.removeEventListener(Event.ENTER_FRAME,this.updateAction);
         }
      }
      
      public function getActionId() : String
      {
         return this.actionId;
      }
      
      public function getCharacter() : MovieClip
      {
         return this.characterClip;
      }
      
      public function changeDirection(param1:Number) : void
      {
      }
      
      public function cleanUp() : void
      {
         if(this.avatarClip != null)
         {
            this.avatarClip.removeEventListener(Event.ENTER_FRAME,this.updateAction);
         }
         this.avatarClip = null;
         this.characterClip = null;
         this.actionParams = null;
      }
      
      protected function updateAction(param1:Event) : void
      {
      }
      
      protected function onActionComplete() : void
      {
         this.avatarClip.removeEventListener(Event.ENTER_FRAME,this.updateAction);
         dispatchEvent(new AvatarActionEvent(AvatarActionEvent.ACTION_COMPLETE,this.actionId,0,this.actionParams,""));
      }
   }
}

