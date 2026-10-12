package Widgets.Tooltips
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class PersistantMovieClipTooltip extends MovieClipTooltip
   {
      
      private var m_active:Boolean;
      
      private var m_askHide:Boolean;
      
      private var tooltipElement:MovieClip;
      
      private var m_tooltipSeperateElement:Boolean;
      
      public function PersistantMovieClipTooltip(element:MovieClip, showFrameNum:int = 2, hideFrameNum:int = 1, tooltipName:String = null)
      {
         super(element,showFrameNum,hideFrameNum);
         if(Boolean(element[tooltipName]) && element[tooltipName] is MovieClip)
         {
            this.tooltipElement = element[tooltipName] as MovieClip;
            this.m_tooltipSeperateElement = true;
            this.tooltipElement.visible = false;
         }
         else
         {
            this.tooltipElement = element;
            this.m_tooltipSeperateElement = false;
         }
      }
      
      override protected function show(event:MouseEvent) : void
      {
         this.m_askHide = false;
         super.show(event);
         if(this.m_tooltipSeperateElement)
         {
            this.tooltipElement.visible = true;
         }
         this.tooltipElement.addEventListener(MouseEvent.ROLL_OVER,this.onActive);
         this.tooltipElement.addEventListener(MouseEvent.ROLL_OUT,this.onDeactivate);
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         this.m_askHide = true;
         this.attemptHide();
      }
      
      override public function release() : void
      {
         this.tooltipElement.removeEventListener(MouseEvent.ROLL_OVER,this.onActive);
         this.tooltipElement.removeEventListener(MouseEvent.ROLL_OUT,this.onDeactivate);
         super.release();
      }
      
      private function attemptHide() : void
      {
         if(!this.m_active && this.m_askHide)
         {
            super.hide(null);
         }
      }
      
      private function onActive(event:MouseEvent) : void
      {
         super.show(null);
         this.m_active = true;
      }
      
      private function onDeactivate(event:MouseEvent) : void
      {
         this.m_active = false;
         this.attemptHide();
      }
      
      override protected function onHideComplete() : void
      {
         this.tooltipElement.removeEventListener(MouseEvent.ROLL_OVER,this.onActive);
         this.tooltipElement.removeEventListener(MouseEvent.ROLL_OUT,this.onDeactivate);
         if(this.m_tooltipSeperateElement)
         {
            this.tooltipElement.visible = false;
         }
      }
   }
}

