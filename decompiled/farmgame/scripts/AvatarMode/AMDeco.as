package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.DecoAvatarAction;
   import Classes.MapResource;
   import flash.geom.Point;
   
   public class AMDeco extends AMActionState
   {
      
      private var m_decoAvatar:DecoAvatarAction;
      
      public function AMDeco(avatar:FarmAvatar, resource:MapResource)
      {
         super(avatar,resource);
         this.m_decoAvatar = resource as DecoAvatarAction;
      }
      
      override public function update(delta:Number) : void
      {
         if(m_actionStarted)
         {
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      override public function removed() : void
      {
         super.removed();
         this.m_decoAvatar.onPathingCompleted();
      }
      
      override protected function getActionPosition() : Point
      {
         return m_resource.hasOwnProperty("pos_mc") ? m_resource["pos_mc"].getPosition().toVector2() : super.getActionPosition();
      }
   }
}

