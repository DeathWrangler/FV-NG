package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Events.AvatarEvent;
   import Managers.AvatarRetentionExperimentUtil;
   
   public class AMPath extends AvatarState
   {
      
      private var m_destX:int;
      
      private var m_destY:int;
      
      private var m_minDistance:Number;
      
      public function AMPath(avatar:FarmAvatar, destX:int, destY:int, minDistance:Number)
      {
         super(avatar);
         this.m_destX = destX;
         this.m_destY = destY;
         this.m_minDistance = minDistance;
      }
      
      override public function enter() : void
      {
         var foundPath:Boolean = false;
         super.enter();
         Global.world.addEventListener(AvatarEvent.COMPLETED,this.onPathingCompleted);
         if(AvatarRetentionExperimentUtil.inLockedExperiment())
         {
            foundPath = false;
         }
         else
         {
            foundPath = m_avatar.walkTo(this.m_destX,this.m_destY,this.m_minDistance);
         }
         if(foundPath == false)
         {
            m_avatar.getStateMachine().noPath = true;
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      override public function exit() : void
      {
         Global.world.removeEventListener(AvatarEvent.COMPLETED,this.onPathingCompleted);
      }
      
      override public function getInterrupt() : int
      {
         return FULL_INTERRUPT;
      }
      
      public function onPathingCompleted(e:AvatarEvent) : void
      {
         if(e.avatar == m_avatar)
         {
            m_avatar.getStateMachine().removeState(this);
         }
      }
   }
}

