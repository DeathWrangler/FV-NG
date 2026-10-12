package Display.Dialogs
{
   import Display.FarmDynamicDialog;
   import Events.UIEvent;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CutsceneDialog extends FarmDynamicDialog
   {
      
      public static const CUTSCENE_IMPORT:String = "cutscene_import";
      
      private var m_movie:MovieClip = null;
      
      private var m_shouldPlayImmediately:Boolean = true;
      
      public function CutsceneDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setShortcutAttribute("mainMovie",ImageController.ATTRIBUTE_SOURCE,this.getImport(CUTSCENE_IMPORT));
      }
      
      override public function show(addToQueue:Boolean = false, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         if(addToQueue == true)
         {
            this.m_shouldPlayImmediately = false;
            this.getView().addEventListener(UIEvent.DISPLAYED_FROM_DIALOG_QUEUE,this.onDisplayedFromQueue);
         }
         super.show(addToQueue);
      }
      
      override protected function onContentLoaded(controller:BaseWidgetController) : void
      {
         if(controller.getName() == "mainMovie")
         {
            this.m_movie = controller.getView().getChildAt(0) as MovieClip;
            if(this.m_movie != null)
            {
               if(this.m_shouldPlayImmediately == true)
               {
                  this.m_movie.gotoAndPlay(1);
               }
               else
               {
                  this.m_movie.stop();
               }
               this.m_movie.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            }
         }
      }
      
      private function onDisplayedFromQueue(event:Event) : void
      {
         this.getView().removeEventListener(UIEvent.DISPLAYED_FROM_DIALOG_QUEUE,this.onDisplayedFromQueue);
         if(this.m_movie != null)
         {
            this.m_movie.gotoAndPlay(1);
         }
         this.m_shouldPlayImmediately = true;
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var movie:MovieClip = event.target as MovieClip;
         if(movie != null && movie == this.m_movie)
         {
            if(this.m_movie.currentFrame == this.m_movie.totalFrames)
            {
               this.m_movie.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
               this.destroy();
            }
         }
      }
   }
}

