package Display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AskForMoreButton extends GenericButton
   {
      
      public static var GREYED_OUT:String = "grey";
      
      public function AskForMoreButton(target_mc:MovieClip, clickCallback:Function = null, val:String = "", overlayName:String = "")
      {
         target_mc.addFrameScript(4,frameScriptTextUpdate);
         super(target_mc,clickCallback,val,overlayName);
      }
      
      override public function set state(newState:String) : void
      {
         switch(newState)
         {
            case GREYED_OUT:
               m_target.gotoAndStop(4);
               m_state = GREYED_OUT;
               break;
            default:
               super.state = newState;
         }
      }
      
      public function greyOut() : void
      {
         m_target.addFrameScript(4,frameScriptTextUpdate);
         m_enterFrameOn = false;
         if(!m_enableHitState || m_enableHitState && m_state != GREYED_OUT)
         {
            m_state = GREYED_OUT;
            Global.stage.invalidate();
            m_target.addEventListener(Event.RENDER,updateText);
            m_target.gotoAndStop(m_target.totalFrames);
            m_target.gotoAndStop(5);
            turnOff();
            m_target.visible = true;
            m_overlay.visible = true;
         }
      }
   }
}

