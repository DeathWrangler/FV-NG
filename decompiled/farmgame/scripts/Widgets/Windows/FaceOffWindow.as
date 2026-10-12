package Widgets.Windows
{
   import Managers.FaceOffManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FaceOffFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FaceOffWindow extends FarmWindow
   {
      
      protected var m_faceOffFrame:FaceOffFrame = null;
      
      private var firstTime:Boolean;
      
      public function FaceOffWindow(dialogAssetUrl:String)
      {
         super(dialogAssetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new FarmAnimatedTextButton(m_window["whatisthis_mc"] as MovieClip,"FaceOffWhatIsThis",this.onWhatIsThisClick));
         this.displayFaceOffFrame();
      }
      
      private function displayFaceOffFrame() : void
      {
         if(m_window["main_mc"])
         {
            this.m_faceOffFrame = new FaceOffFrame(m_window.main_mc,this);
            addWidget(this.m_faceOffFrame);
         }
         if(m_window["title_tf"])
         {
            addWidget(new ZwTextField(m_window.title_tf,(m_window.title_tf as TextField).text));
         }
         if(!Global.player.getSeenFlag(FaceOffManager.getInstance().getFaceOffName()) && Boolean(m_window["tutorial_mc"]))
         {
            m_window["tutorial_mc"].visible = true;
            (m_window["tutorial_mc"] as MovieClip).play();
            Global.player.setSeenFlag(FaceOffManager.getInstance().getFaceOffName());
         }
      }
      
      public function update() : void
      {
         this.m_faceOffFrame.update();
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         m_window["tutorial_mc"].visible = true;
         (m_window["tutorial_mc"] as MovieClip).play();
      }
   }
}

