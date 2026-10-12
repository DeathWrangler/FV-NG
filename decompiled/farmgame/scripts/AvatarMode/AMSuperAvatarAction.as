package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import MyLife.Assets.Avatar.AvatarActions.AnimationAction;
   import flash.geom.Point;
   
   public class AMSuperAvatarAction extends AMMultiPlotAction
   {
      
      public static const SUPER_AVATAR_ACTION_SIZE_X:int = 2;
      
      public static const SUPER_AVATAR_ACTION_SIZE_Y:int = 2;
      
      protected var m_resourceAction:int;
      
      protected var m_totalActionTime:int;
      
      public function AMSuperAvatarAction(avatar:FarmAvatar, plots:Array, centerPos:Point, resourceAction:int, totalActionTime:int)
      {
         super(avatar,plots,centerPos);
         this.m_resourceAction = resourceAction;
         this.m_totalActionTime = totalActionTime;
      }
      
      override protected function hide() : void
      {
         Global.selectedAvatar.stopOverlay();
         m_avatar.setPosition(Math.max(m_centerPos.x - m_avatar.getSize().x / 2 - 0.1,0),Math.max(m_centerPos.y - m_avatar.getSize().y / 2 - 0.1,0));
         m_avatar.conditionallyReattach();
         m_avatar.getCharacter().doAvatarAction(AnimationAction.ARM_SHUFFLE);
      }
      
      override protected function show() : void
      {
         m_avatar.conditionallyReattach();
         m_avatar.getCharacter().doAvatarAction("stand");
      }
      
      protected function getNumAvailableActions() : int
      {
         return Global.player.getNumSuperAvatarActions(this.m_resourceAction);
      }
      
      protected function getNumPlotsPerUse() : int
      {
         return SUPER_AVATAR_ACTION_SIZE_X * SUPER_AVATAR_ACTION_SIZE_Y;
      }
      
      override protected function getEnergyForPlot(plotIndex:int) : int
      {
         var energy:int = 0;
         if(0 == plotIndex)
         {
            energy = 1;
         }
         return energy;
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var numPlotsSucceeded:int = 0;
         if(this.getNumAvailableActions() > 0)
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / this.m_totalActionTime;
               if(progress > 1)
               {
                  numPlotsSucceeded = this.doAction();
                  m_avatar.getStateMachine().removeState(this);
                  if(0 == numPlotsSucceeded || this.getNumAvailableActions() == 0)
                  {
                     m_avatar.getStateMachine().removeMachineStates();
                     this.onRunOutOfActions();
                  }
               }
               else
               {
                  this.updateActionProgress(progress);
               }
            }
         }
         else
         {
            m_avatar.getStateMachine().removeState(this);
         }
      }
      
      protected function onRunOutOfActions() : void
      {
      }
      
      protected function doAction() : int
      {
         return 0;
      }
      
      protected function updateActionProgress(progress:Number) : void
      {
      }
   }
}

