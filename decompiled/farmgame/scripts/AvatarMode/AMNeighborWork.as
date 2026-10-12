package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.NeighborVisitAvatar;
   import Classes.util.ZLocUtils;
   
   public class AMNeighborWork extends AMActionState
   {
      
      public function AMNeighborWork(avatar:FarmAvatar)
      {
         super(avatar,null);
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var neighborAvatar:NeighborVisitAvatar = null;
         if(m_actionStarted)
         {
            m_actionTime += delta;
            progress = m_actionTime / Global.farmGameSettingsManager.getNumber("plowTime");
            if(progress > 1)
            {
               m_avatar.getStateMachine().removeState(this);
               m_avatar.setActionProgress("");
               neighborAvatar = m_avatar as NeighborVisitAvatar;
               if(neighborAvatar)
               {
                  neighborAvatar.executeActions();
               }
            }
            else
            {
               m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Working"),progress);
            }
         }
      }
      
      override protected function conditionallyPath() : Boolean
      {
         return false;
      }
   }
}

