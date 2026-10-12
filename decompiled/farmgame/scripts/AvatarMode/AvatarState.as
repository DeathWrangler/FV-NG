package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Engine.Classes.State;
   import flash.geom.Point;
   
   public class AvatarState extends State
   {
      
      protected static const DISTANCE_EPSILON:Number = 1.25;
      
      protected var m_avatar:FarmAvatar;
      
      public function AvatarState(avatar:FarmAvatar)
      {
         super();
         this.m_avatar = avatar;
      }
      
      public function getNumActions() : int
      {
         return 0;
      }
      
      protected function conditionallyPath() : Boolean
      {
         var destPos:Point = null;
         var avatarPos:Point = null;
         var distance:Number = NaN;
         var isPathable:Boolean = false;
         var pathing:Boolean = false;
         if(!Global.worldManager.isVisiting())
         {
            destPos = this.getActionPosition();
            avatarPos = this.m_avatar.getPosition().toVector2();
            distance = this.getActionDistance();
            isPathable = Global.world.ispathable(destPos.x,destPos.y);
            if(Boolean(distance >= 0 && destPos) && Boolean(destPos.subtract(avatarPos).length > distance) && isPathable)
            {
               if(this.m_avatar.getStateMachine().noPath == false)
               {
                  this.m_avatar.getStateMachine().addState(new AMPath(this.m_avatar,destPos.x,destPos.y,this.getActionDistance()));
                  pathing = true;
               }
               else
               {
                  this.m_avatar.getStateMachine().noPath = false;
               }
            }
         }
         return pathing;
      }
      
      protected function getActionPosition() : Point
      {
         return null;
      }
      
      protected function getActionDistance() : Number
      {
         return DISTANCE_EPSILON;
      }
      
      protected function abortActions() : void
      {
         this.m_avatar.getStateMachine().removeAllStates();
         Global.world.removeGameMode(Global.world.getTopGameMode());
         Global.world.setDefaultGameMode();
      }
   }
}

