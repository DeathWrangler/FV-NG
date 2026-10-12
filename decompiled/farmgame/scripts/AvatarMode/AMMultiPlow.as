package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Plot;
   
   public class AMMultiPlow extends AvatarState
   {
      
      protected var m_plots:Array = [];
      
      public function AMMultiPlow(avatar:FarmAvatar, plots:Array)
      {
         super(avatar);
         this.m_plots = plots;
      }
      
      override public function getNumActions() : int
      {
         return this.m_plots.length;
      }
      
      override public function added() : void
      {
         var plot:Plot = null;
         super.added();
         for(var plotIdx:int = 0; plotIdx < this.m_plots.length; plotIdx++)
         {
            plot = this.m_plots[plotIdx] as Plot;
            plot.setAlpha(0.6);
            plot.lock();
         }
      }
      
      override public function removed() : void
      {
         var plot:Plot = null;
         super.removed();
         for(var plotIdx:int = 0; plotIdx < this.m_plots.length; plotIdx++)
         {
            plot = this.m_plots[plotIdx] as Plot;
            plot.setAlpha(1);
            plot.unlock();
         }
      }
      
      override public function enter() : void
      {
         super.enter();
         this.pumpQueue();
      }
      
      override public function reenter() : void
      {
         this.pumpQueue();
      }
      
      protected function pumpQueue() : void
      {
         var plot:Array = null;
         if(this.m_plots.length)
         {
            plot = this.m_plots.splice(0,1);
            plot[0].unlock();
            m_avatar.getStateMachine().addState(new AMPlow(m_avatar,plot[0]));
         }
         else
         {
            m_avatar.getStateMachine().removeState(this);
         }
      }
   }
}

