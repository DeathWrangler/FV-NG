package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmersMarketInnovationOrderboardTaskFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmersMarketInnovationGenericOrderboardWindow extends FarmWindowWithTutorial
   {
      
      private var m_featureName:String = null;
      
      private var managerObject:Object;
      
      protected const TASKS_MC:String = "tasks_mc";
      
      protected const LOADING_TF:String = "loading_tf";
      
      protected var m_taskFrame:FarmersMarketInnovationOrderboardTaskFrame;
      
      protected var m_loadingTf:ZwTextField;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected var m_DumptutorialScene:int = 0;
      
      public function FarmersMarketInnovationGenericOrderboardWindow(featureNameDuplicate:String, windowAssetRelUrl:String, managerObjectDuplicate:Object, totalNumScenes:int = -1, modal:Boolean = true, bAddClickBlocker:Boolean = false, closeAfterTut:Boolean = false, bypassSeenFlag:Boolean = false)
      {
         this.m_featureName = featureNameDuplicate;
         this.managerObject = managerObjectDuplicate;
         var dialogURL:String = windowAssetRelUrl;
         var totalScenes:int = totalNumScenes;
         super(featureNameDuplicate,dialogURL,totalScenes);
      }
      
      override protected function postLoadComplete() : void
      {
         var showLoadingTf:Boolean = false;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TASKS_MC))
         {
            this.m_taskFrame = new FarmersMarketInnovationOrderboardTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName,this.managerObject);
            this.m_taskFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.LOADING_TF))
         {
            showLoadingTf = this.getManager.getTasks().length == 0;
            this.m_loadingTf = new ZwTextField(m_window[this.LOADING_TF],"Loading task...");
            this.m_loadingTf.visible = showLoadingTf;
         }
         if(m_window.hasOwnProperty(this.DUMPFTUE_MC))
         {
            this.m_DumpTutorial = addWidget(new ZwFrame(m_window[this.DUMPFTUE_MC]),false) as ZwFrame;
            if(m_window[this.DUMPFTUE_MC].okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.dumpFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onDumpTutorialOkayButtonClick));
            }
         }
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
         }
         this.m_taskFrame.refresh();
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      public function showDumpTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_DumptutorialScene = 1;
         if(this.m_DumpTutorial)
         {
            element = this.m_DumpTutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window[this.DUMPFTUE_MC].okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_DumpTutorial.visible = true;
         }
      }
      
      public function get getManager() : Object
      {
         return this.managerObject;
      }
      
      private function onDumpTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_DumptutorialScene < 2)
         {
            ++this.m_DumptutorialScene;
            (this.m_DumpTutorial.element as MovieClip).gotoAndStop(this.m_DumptutorialScene);
         }
         else
         {
            this.hideDumpTutorial();
         }
      }
      
      private function hideDumpTutorial() : void
      {
         (this.m_DumpTutorial.element as MovieClip).stop();
         this.m_DumpTutorial.visible = false;
      }
      
      public function isTaskClicked() : Boolean
      {
         if(this.m_taskFrame)
         {
            return this.m_taskFrame.isTaskClicked();
         }
         return false;
      }
   }
}

