package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class TravelDialogTutorialWindow extends FarmWindow
   {
      
      private var m_tutorial:ZwFrame = null;
      
      private var m_totalNumScenes:int = 4;
      
      private var m_tutorialScene:int = 0;
      
      private var m_callback:Function = null;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_faqTf:FarmAnimatedButton;
      
      private var m_faqLink:String = null;
      
      private const FAQ_MC:String = "faq_mc";
      
      private var m_AddFAQBtn:Boolean = false;
      
      public function TravelDialogTutorialWindow(windowAssetRelUrl:String, totalNumScenes:int = -1, callback:Function = null, AddFAQBtn:Boolean = false, faqLink:String = null)
      {
         super(windowAssetRelUrl);
         this.m_totalNumScenes = totalNumScenes;
         this.m_callback = callback;
         this.m_AddFAQBtn = AddFAQBtn;
         this.m_faqLink = faqLink;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.tutorial_mc)
         {
            this.m_tutorial = addWidget(new ZwFrame(m_window.tutorial_mc),false) as ZwFrame;
            if(this.m_totalNumScenes == -1)
            {
               this.m_totalNumScenes = this.m_tutorial.element.totalFrames;
            }
            if(m_window.tutorial_mc.okay_bt)
            {
               this.m_tutorial.addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onTutorialOkayButtonClick)) as FarmAnimatedTextButton;
            }
            this.showTutorial();
         }
         if(this.m_AddFAQBtn)
         {
            if(m_window.tutorial_mc.hasOwnProperty(this.FAQ_MC))
            {
               if(this.m_faqLink != "")
               {
                  this.m_faqTf = addWidget(new FarmAnimatedButton(m_window.tutorial_mc[this.FAQ_MC],this.onFAQClick)) as FarmAnimatedButton;
                  (m_window.tutorial_mc[this.FAQ_MC] as DisplayObject).visible = false;
               }
            }
         }
      }
      
      private function onFAQClick(event:MouseEvent) : void
      {
         if(this.m_faqLink != "")
         {
            navigateToURL(new URLRequest(this.m_faqLink),"_blank");
         }
      }
      
      protected function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_tutorialScene = 1;
         if(this.m_tutorial != null)
         {
            element = this.m_tutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.tutorial_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_tutorial.visible = true;
         }
      }
      
      private function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_tutorialScene < this.m_totalNumScenes)
         {
            ++this.m_tutorialScene;
            if(this.m_tutorialScene == this.m_totalNumScenes && this.m_AddFAQBtn && this.m_faqLink != "")
            {
               this.m_faqTf.visible = true;
               this.m_faqTf.alpha = 1;
            }
            (this.m_tutorial.element as MovieClip).play();
         }
         else
         {
            if(this.m_callback != null)
            {
               this.m_callback();
            }
            close();
         }
      }
   }
}

