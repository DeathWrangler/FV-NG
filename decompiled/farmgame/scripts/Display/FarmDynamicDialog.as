package Display
{
   import Engine.Managers.InputManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.interfaces.IDialogEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.utils.getQualifiedClassName;
   
   public class FarmDynamicDialog extends DynamicDialog implements IDialogEvent
   {
      
      protected var m_cursorId:int = 0;
      
      protected var m_loaded:Boolean = false;
      
      protected var m_showOnLoadComplete:Boolean = false;
      
      private var m_zaspLoadHandle:int = 0;
      
      public function FarmDynamicDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function createDialog(dialogName:String, classRef:Class = null) : FarmDynamicDialog
      {
         var result:FarmDynamicDialog = null;
         if(classRef == null)
         {
            classRef = FarmDynamicDialog;
         }
         var dynamicDialog:DynamicDialog = MT4DManager.getInstance().getDialog(dialogName);
         if(Boolean(dynamicDialog) && Boolean(classRef))
         {
            result = DynamicDialog.createFromExisting(classRef,dynamicDialog) as FarmDynamicDialog;
            if(result is FarmDynamicDialog == false)
            {
               throw new IllegalOperationError("New dialogs created through FarmDynamicDialog must extend that class");
            }
         }
         return result;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         UI.removeCursor(this.m_cursorId);
         FreezeManager.thaw();
         if(UI.isShowingPopup() == false)
         {
            Utilities.toggleInputAndChildren(Global.ui,true);
         }
         InputManager.enableInput();
      }
      
      public function show(addToQueue:Boolean = false, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         this.listen(Event.COMPLETE,this.onDialogLoaded);
         analyzeDialog();
         InputManager.disableInput();
         Utilities.toggleInputAndChildren(Global.ui,false);
         this.m_cursorId = UI.setCursor(null);
         if(this.m_loaded == false)
         {
            this.getView().visible = false;
            this.m_showOnLoadComplete = true;
            if(Boolean(GlobalEngine.zaspManager) && !this.m_zaspLoadHandle)
            {
               this.m_zaspLoadHandle = GlobalEngine.zaspManager.zaspWaitStart("DIALOG",getQualifiedClassName(this));
            }
         }
         else
         {
            FreezeManager.freezeRender();
         }
         UI.displayPopup(getView(),addToQueue,popupName,checkDuplicates);
         if(!addToQueue)
         {
            this.recenter();
         }
         addListener(Global.stage,FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         addListener(Global.stage,Event.RESIZE,this.onResize);
      }
      
      public function isCurrentlyLoading() : Boolean
      {
         return this.m_loaded == false && this.m_showOnLoadComplete;
      }
      
      public function onDialogLoaded(event:Event) : void
      {
         this.m_loaded = true;
         if(this.m_showOnLoadComplete)
         {
            this.m_showOnLoadComplete = false;
            this.getView().visible = true;
            FreezeManager.freezeRender();
            if(GlobalEngine.zaspManager)
            {
               GlobalEngine.zaspManager.zaspPopup();
               if(this.m_zaspLoadHandle > 0)
               {
                  GlobalEngine.zaspManager.zaspWaitEnd(this.m_zaspLoadHandle);
                  this.m_zaspLoadHandle = 0;
               }
            }
         }
      }
      
      private function onFullScreen(event:FullScreenEvent) : void
      {
         this.recenter();
      }
      
      private function onResize(event:Event = null) : void
      {
         this.recenter();
      }
      
      public function onDialogCreate() : void
      {
         FarmStatsManager.count("dialog",this.m_name.toLowerCase(),"open_view","","","",m_index);
      }
      
      public function onDialogDestroy() : void
      {
         FarmStatsManager.count("dialog",this.m_name.toLowerCase(),"close_view","","","",m_index);
      }
      
      public function onDialogButtonPressed(controller:ButtonController) : void
      {
         FarmStatsManager.count("dialog",this.m_name.toLowerCase(),"button_" + controller.getName().toLowerCase(),"","","",m_index);
      }
      
      public function setVisibility(isVisible:Boolean) : void
      {
         this.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,isVisible);
      }
      
      public function toggleVisibleAndObstruct(shortcutName:String, isVisible:Boolean) : void
      {
         this.setShortcutAttribute(shortcutName,BaseWidgetView.ATTRIBUTE_OBSTRUCT,isVisible);
         this.setShortcutAttribute(shortcutName,BaseWidgetView.ATTRIBUTE_VISIBLE,isVisible);
      }
   }
}

