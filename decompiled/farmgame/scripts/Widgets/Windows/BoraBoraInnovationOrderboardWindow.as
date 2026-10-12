package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BoraBoraInnovationOrderboardTaskFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BoraBoraInnovationOrderboardWindow extends FarmWindowWithTutorial
   {
      
      private var m_featureName:String = null;
      
      private var managerObject:Object;
      
      protected const TASKS_MC:String = "tasks_mc";
      
      protected const LOADING_TF:String = "loading_tf";
      
      protected var m_taskFrame:BoraBoraInnovationOrderboardTaskFrame;
      
      protected var m_loadingTf:ZwTextField;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected var m_DumptutorialScene:int = 0;
      
      private var m_boramoney_tf:ZwTextField;
      
      private var m_lockOutMc:MovieClip;
      
      private var m_estimatedBMMc:MovieClip;
      
      private var m_estimate_tf:ZwTextField;
      
      public function BoraBoraInnovationOrderboardWindow(featureNameDuplicate:String, windowAssetRelUrl:String, managerObjectDuplicate:Object, totalNumScenes:int = -1, modal:Boolean = true, bAddClickBlocker:Boolean = false, closeAfterTut:Boolean = false, bypassSeenFlag:Boolean = false)
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
         var boraMoney_mc:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TASKS_MC))
         {
            this.m_taskFrame = new BoraBoraInnovationOrderboardTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName,this.managerObject);
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
         if(m_window.hasOwnProperty("total_coupons_mc"))
         {
            boraMoney_mc = m_window["total_coupons_mc"] as MovieClip;
            if(boraMoney_mc.hasOwnProperty("bora_counter_tf"))
            {
               addWidget(this.m_boramoney_tf = new ZwTextField(boraMoney_mc["bora_counter_tf"],this.manager.getOrderboardProgress().toString()));
            }
            boraMoney_mc.visible = true;
         }
         if(m_window.hasOwnProperty("lockout_mc"))
         {
            this.m_lockOutMc = m_window["lockout_mc"] as MovieClip;
            this.m_lockOutMc.visible = false;
         }
         if(m_window.hasOwnProperty("estimated_bm_mc"))
         {
            this.m_estimatedBMMc = m_window["estimated_bm_mc"] as MovieClip;
            this.m_estimatedBMMc.visible = true;
            if(this.m_estimatedBMMc.hasOwnProperty("estimate_tf"))
            {
               addWidget(this.m_estimate_tf = new ZwTextField(this.m_estimatedBMMc["estimate_tf"],""));
               this.m_estimate_tf.text = (this.manager.MAX_CYCLE_BORABORA_LIMIT - this.manager.getMaxTotalBoraboraMoney()).toString();
               this.m_estimate_tf.visible = true;
            }
         }
      }
      
      public function refreshTaskFrame() : void
      {
         var totalBorabora:int = 0;
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
         }
         if(this.m_taskFrame)
         {
            this.m_taskFrame.refresh();
         }
         if(this.m_boramoney_tf)
         {
            this.m_boramoney_tf.text = this.manager.getOrderboardProgress().toString();
         }
         if(this.m_estimate_tf)
         {
            totalBorabora = this.manager.MAX_CYCLE_BORABORA_LIMIT - this.manager.getMaxTotalBoraboraMoney();
            if(totalBorabora <= 0)
            {
               totalBorabora = this.manager.MAX_CYCLE_BORABORA_LIMIT;
            }
            this.m_estimate_tf.text = totalBorabora.toString();
         }
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
         if(this.managerObject.isEnoughBoraboraMoney())
         {
            this.m_lockOutMc.visible = true;
         }
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
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance("BoraBoraInnovation");
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
      
      override public function close() : void
      {
         this.getManager.refreshDecoPanels();
         this.getManager.refreshBoraboraMoney();
         this.getManager.mainWindow.untintWindow();
         this.getManager.mainWindow.enableInput = true;
         super.close();
      }
   }
}

