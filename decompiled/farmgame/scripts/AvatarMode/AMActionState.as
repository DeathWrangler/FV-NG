package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.MapResource;
   import Engine.Classes.State;
   import flash.geom.Point;
   
   public class AMActionState extends AvatarState
   {
      
      protected var m_resource:MapResource;
      
      protected var m_actionStarted:Boolean;
      
      protected var m_actionTime:Number = 0;
      
      public function AMActionState(avatar:FarmAvatar, resource:MapResource)
      {
         super(avatar);
         this.m_resource = resource;
      }
      
      override public function getNumActions() : int
      {
         return 1;
      }
      
      public function getResource() : MapResource
      {
         return this.m_resource;
      }
      
      override public function added() : void
      {
         super.added();
         if(this.m_resource)
         {
            this.m_resource.setAlpha(0.6);
            this.m_resource.lock();
         }
      }
      
      override public function removed() : void
      {
         super.removed();
         if(this.m_resource)
         {
            this.m_resource.setAlpha(1);
            this.m_resource.unlock();
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         if(conditionallyPath() == false)
         {
            this.m_actionStarted = true;
         }
      }
      
      override public function reenter() : void
      {
         if(conditionallyPath() == false)
         {
            this.m_actionStarted = true;
         }
      }
      
      override public function exit() : void
      {
         m_avatar.setActionProgress(null);
         super.exit();
      }
      
      override protected function getActionPosition() : Point
      {
         return this.m_resource != null ? this.m_resource.getPosition().toVector2() : new Point();
      }
      
      override public function getInterrupt() : int
      {
         return this.m_actionStarted ? State.NO_INTERRUPT : State.NORMAL_INTERRUPT;
      }
   }
}

