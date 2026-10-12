package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Managers.AvatarRetentionExperimentUtil;
   
   public class AMUnwither extends AMActionState
   {
      
      private var m_plot:Plot;
      
      public function AMUnwither(avatar:FarmAvatar, plot:Plot)
      {
         super(avatar,plot);
         this.m_plot = plot;
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         if(m_actionStarted)
         {
            m_actionTime += delta;
            progress = m_actionTime / Global.farmGameSettingsManager.getNumber("unwitherTime",1);
            if(progress > 1 || AvatarRetentionExperimentUtil.inNoWaitExperiment())
            {
               this.m_plot.unwither();
               m_avatar.getStateMachine().removeState(this);
            }
            else
            {
               m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Unwithering"),progress);
            }
         }
      }
   }
}

