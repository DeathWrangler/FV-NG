package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LimboInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LimboInnovationWindow extends FarmWindow
   {
      
      private static const SUB_TITLE_TXT:String = "description_tf";
      
      private static const WHAT_IS_THIS:String = "whatisthis_bt";
      
      private static const TITLE_TXT:String = "title_tf";
      
      private static const SLOTS:String = "slots_mc";
      
      private var m_featureName:String;
      
      protected var m_tutorial:ZwFrame = null;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_buildingContainerFrame:GenericSlotContainerFrame;
      
      private const TITLE_TEXT:String = "_title";
      
      private const DESCP_TEXT:String = "_descrp";
      
      private const WHATS_TEXT:String = "_whatsthis";
      
      private var m_awesomeMc:MovieClip;
      
      public function LimboInnovationWindow(assetUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TXT))
         {
            addWidget(new ZwTextField(m_window[TITLE_TXT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_TEXT)),true);
         }
         if(m_window.hasOwnProperty(SUB_TITLE_TXT))
         {
            addWidget(new ZwTextField(m_window[SUB_TITLE_TXT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.DESCP_TEXT)),true);
         }
         if(m_window.hasOwnProperty(WHAT_IS_THIS))
         {
            addWidget(new FarmAnimatedTextButton(m_window[WHAT_IS_THIS],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.WHATS_TEXT),this.onHowDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(SLOTS))
         {
            this.m_buildingContainerFrame = new GenericSlotContainerFrame(m_window[SLOTS],LimboInnovationSlot,null,this);
            addWidget(this.m_buildingContainerFrame);
            this.m_buildingContainerFrame.setData(LimboInnovationManager.getInstance().buildingConfig());
         }
         this.generateTutorialScreen();
      }
      
      private function generateTutorialScreen() : void
      {
         this.m_tutorial = addWidget(new ZwFrame(m_window.tutorial_mc),false) as ZwFrame;
         if(Boolean(m_window.tutorial_mc.awesome_bt) && this.m_tutorialButton == null)
         {
            this.m_tutorial.addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(m_window.tutorial_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Awesome"),this.onTutorialOkayButtonClick)) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("tutorial_mc") && Boolean(m_window.tutorial_mc.hasOwnProperty("interactable_mc")))
         {
            this.m_awesomeMc = m_window.tutorial_mc.interactable_mc as MovieClip;
            this.m_awesomeMc.visible = false;
         }
         var tutorialSeenFlag:String = this.m_featureName + "_Tutorial";
         if(!Global.player.getSeenFlag(tutorialSeenFlag))
         {
            Global.player.setSeenFlag(tutorialSeenFlag);
            this.showTutorial();
         }
         else
         {
            this.hideTutorial();
         }
      }
      
      protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         FarmStatsManager.count(this.m_featureName,"FTUE","completed","click");
         this.hideTutorial();
      }
      
      private function onHowDoesThisWorkClick(e:Event) : void
      {
         this.showTutorial();
         if(this.m_tutorial == null)
         {
            this.m_tutorial = addWidget(new ZwFrame(m_window.tutorial_mc),false) as ZwFrame;
         }
      }
      
      protected function showTutorial() : void
      {
         if(this.m_tutorial != null)
         {
            this.m_tutorial.visible = true;
            if(this.m_awesomeMc)
            {
               this.m_awesomeMc.visible = true;
               this.m_awesomeMc.play();
            }
            FarmStatsManager.count(this.m_featureName,"FTUE","started","click");
         }
      }
      
      protected function hideTutorial() : void
      {
         (this.m_tutorial.element as MovieClip).stop();
         if(this.m_awesomeMc)
         {
            this.m_awesomeMc.visible = false;
         }
         this.m_tutorial.visible = false;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
   }
}

