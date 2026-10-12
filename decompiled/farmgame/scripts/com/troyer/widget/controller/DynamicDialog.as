package com.troyer.widget.controller
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.interfaces.IDialogEvent;
   import com.troyer.widget.style.DialogLook;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class DynamicDialog extends BaseWidgetController
   {
      
      private var m_importList:Dictionary;
      
      protected var m_center:Boolean = true;
      
      private var m_shortcutMap:Dictionary;
      
      private var m_conflictMap:Dictionary;
      
      private var m_viewsLoading:int = 0;
      
      private var m_look:DialogLook;
      
      public function DynamicDialog(param1:BaseWidgetView)
      {
         super(param1);
         m_index = getTimer();
      }
      
      public static function createFromExisting(param1:Class, param2:DynamicDialog) : DynamicDialog
      {
         var _loc4_:BaseWidgetView = null;
         var _loc5_:Dictionary = null;
         var _loc6_:String = null;
         var _loc3_:DynamicDialog = null;
         if(param2)
         {
            _loc4_ = param2.getView();
            _loc3_ = new param1(_loc4_);
            _loc3_.setAttribute(ATTRIBUTE_NAME,param2.getName());
            _loc4_.setController(_loc3_);
            _loc5_ = param2.getImports();
            if(_loc5_)
            {
               for(_loc6_ in _loc5_)
               {
                  _loc3_.addImport(_loc6_,_loc5_[_loc6_]);
               }
            }
            param2.setView(null);
            param2.destroy();
            _loc3_.initialize();
         }
         return _loc3_;
      }
      
      override public function destroy() : void
      {
         if(this is IDialogEvent)
         {
            (this as IDialogEvent).onDialogDestroy();
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.DIALOG_DESTROY,this));
            MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.DIALOG_DESTROY,this));
         }
         this.m_importList = null;
         this.m_look = null;
         this.m_shortcutMap = null;
         this.m_conflictMap = null;
         super.destroy();
      }
      
      public function analyzeDialog() : void
      {
         var _loc2_:BaseWidgetView = null;
         var _loc3_:BaseWidgetController = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc1_:Array = getFlatChildrenList();
         this.m_shortcutMap = new Dictionary();
         this.m_conflictMap = null;
         this.m_viewsLoading = 0;
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = _loc2_.getController();
            this.m_viewsLoading += _loc3_.loadCount;
            _loc4_ = _loc3_.getGlobalListeners();
            if((Boolean(_loc4_)) && _loc4_.length > 0)
            {
               for each(_loc6_ in _loc4_)
               {
                  addListener(_loc3_,_loc6_,this.onGlobalEvent);
               }
            }
            _loc5_ = _loc3_.getName();
            if(this.m_shortcutMap.hasOwnProperty(_loc5_))
            {
               if(!this.m_conflictMap)
               {
                  this.m_conflictMap = new Dictionary();
               }
               if(this.m_conflictMap.hasOwnProperty(_loc5_))
               {
                  (this.m_conflictMap[_loc5_] as Array).push(_loc2_.getDisplayPath());
               }
               else
               {
                  this.m_conflictMap[_loc5_] = [_loc2_.getDisplayPath()];
               }
            }
            else
            {
               this.m_shortcutMap[_loc5_] = _loc2_.getDisplayPath();
            }
         }
         if(this.m_viewsLoading == 0)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      override public function initialize() : void
      {
         var _loc1_:String = null;
         super.initialize();
         this.analyzeDialog();
         if(Boolean(this.m_conflictMap) && Boolean(this.m_shortcutMap))
         {
            for(_loc1_ in this.m_conflictMap)
            {
               if(this.m_shortcutMap.hasOwnProperty(_loc1_))
               {
                  (this.m_conflictMap[_loc1_] as Array).push(this.m_shortcutMap[_loc1_]);
                  delete this.m_shortcutMap[_loc1_];
               }
            }
         }
         if(this is IDialogEvent)
         {
            (this as IDialogEvent).onDialogCreate();
            dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.DIALOG_CREATE,this));
            MT4DManager.getInstance().dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.DIALOG_CREATE,this));
         }
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         if(this.m_center)
         {
            this.recenter();
         }
      }
      
      public function recenter(param1:DisplayObject = null) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Rectangle = null;
         if(m_view.parent)
         {
            _loc2_ = m_view.getSize();
            if(_loc2_ != null)
            {
               _loc3_ = _loc2_.width;
               _loc4_ = _loc2_.height;
               if(param1 == null)
               {
                  if(m_view.parent != null && m_view.parent.stage != null)
                  {
                     _loc3_ = m_view.parent.stage.stageWidth;
                     _loc4_ = m_view.parent.stage.stageHeight;
                  }
               }
               else if(param1 is BaseWidgetView)
               {
                  _loc5_ = (param1 as BaseWidgetView).getSize();
                  if(_loc5_)
                  {
                     _loc3_ = _loc5_.width;
                     _loc4_ = _loc5_.height;
                  }
               }
               else
               {
                  _loc3_ = param1.width;
                  _loc4_ = param1.height;
               }
               m_view.x = _loc3_ - _loc2_.width >> 1;
               m_view.y = _loc4_ - _loc2_.height >> 1;
            }
         }
      }
      
      protected function onContentLoaded(param1:BaseWidgetController) : void
      {
      }
      
      private function onAddChildView(param1:BaseWidgetController) : void
      {
         this.repositionChildView(param1);
         this.getView().addChild(param1.getView());
      }
      
      private function onRemoveChildView(param1:BaseWidgetController) : void
      {
         this.getView().removeChild(param1.getView());
      }
      
      private function onMoveChildView(param1:BaseWidgetController) : void
      {
         this.repositionChildView(param1);
      }
      
      private function repositionChildView(param1:BaseWidgetController) : void
      {
         var _loc2_:Rectangle = this.getView().getBounds(this.getView().stage);
         param1.getView().x = param1.getView().x - _loc2_.x;
         param1.getView().y = param1.getView().y - _loc2_.y;
      }
      
      public function getShortcutController(param1:String) : BaseWidgetController
      {
         var _loc3_:BaseWidgetController = null;
         var _loc4_:String = null;
         var _loc2_:BaseWidgetController = null;
         if(this.m_shortcutMap)
         {
            if(this.m_shortcutMap.hasOwnProperty(param1))
            {
               _loc3_ = getChildController(this.m_shortcutMap[param1]);
               if(_loc3_)
               {
                  _loc2_ = _loc3_;
               }
               else
               {
                  addError("Shortcut \'" + param1 + "\' no longer exists at path " + this.m_shortcutMap[param1] + " in dialog \'" + m_name + "\'");
               }
            }
            else if(Boolean(this.m_conflictMap) && this.m_conflictMap.hasOwnProperty(param1))
            {
               addError("Duplicate shortcut names exist for name " + param1 + " in dialog \'" + m_name + "\'");
               for each(_loc4_ in this.m_conflictMap[param1])
               {
               }
            }
            else
            {
               addError("Unknown shortcut name: " + param1 + " in dialog \'" + m_name + "\'");
            }
         }
         else
         {
            addError("Shortcut name: " + param1 + " in dialog \'" + m_name + "\' doesnt exist because there are no shortcuts");
         }
         return _loc2_;
      }
      
      public function setShortcutAttribute(param1:String, param2:String, param3:*) : void
      {
         var _loc4_:BaseWidgetController = this.getShortcutController(param1);
         if(_loc4_)
         {
            _loc4_.setAttribute(param2,param3);
         }
      }
      
      public function getShortcutAttribute(param1:String, param2:String) : *
      {
         var _loc3_:* = null;
         var _loc4_:BaseWidgetController = this.getShortcutController(param1);
         if(_loc4_)
         {
            _loc3_ = _loc4_.getAttribute(param2);
         }
         return _loc3_;
      }
      
      public function setShortcutListener(param1:String, param2:String, param3:Function) : void
      {
         var _loc4_:BaseWidgetController = this.getShortcutController(param1);
         if(_loc4_)
         {
            _loc4_.listen(param2,param3);
         }
      }
      
      public function setup() : void
      {
      }
      
      public function addImport(param1:String, param2:*) : void
      {
         if(!this.m_importList)
         {
            this.m_importList = new Dictionary();
         }
         this.m_importList[param1] = param2;
      }
      
      public function getImport(param1:String) : *
      {
         var _loc2_:* = null;
         if(Boolean(this.m_importList) && this.m_importList.hasOwnProperty(param1))
         {
            _loc2_ = this.m_importList[param1];
         }
         return _loc2_;
      }
      
      public function getImports() : Dictionary
      {
         return this.m_importList;
      }
      
      public function setLook(param1:DialogLook) : void
      {
         this.m_look = param1;
      }
      
      public function getLook() : DialogLook
      {
         return this.m_look;
      }
      
      public function setChildAttributes(param1:Array) : void
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         var _loc4_:BaseWidgetController = null;
         for each(_loc2_ in param1)
         {
            if(!_loc2_.hasOwnProperty(Constants.TAG_NAME) || _loc2_[Constants.TAG_NAME] == Constants.ATTRIBUTE_VIEW)
            {
               _loc3_ = _loc2_[Constants.ATTRIBUTE_TARGET];
               _loc4_ = this.getShortcutController(_loc3_);
               if(_loc4_)
               {
                  _loc4_.setAttributes(_loc2_);
               }
               else
               {
                  addError("View \'" + _loc3_ + "\' not found to pass attributes in dialog \'" + m_name + "\'.");
               }
            }
         }
      }
      
      public function set center(param1:Boolean) : void
      {
         this.m_center = param1;
      }
      
      public function get center() : Boolean
      {
         return this.m_center;
      }
      
      private function onGlobalEvent(param1:WidgetControllerEvent) : void
      {
         var _loc2_:BaseWidgetController = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         switch(param1.type)
         {
            case WidgetControllerEvent.BUTTON_PRESSED:
               if(this is IDialogEvent)
               {
                  (this as IDialogEvent).onDialogButtonPressed(param1.getController() as ButtonController);
               }
               break;
            case WidgetControllerEvent.CLOSE:
               this.destroy();
               break;
            case WidgetControllerEvent.BEGIN_DRAG_DIALOG:
               this.m_view.startDrag();
               break;
            case WidgetControllerEvent.END_DRAG_DIALOG:
               this.m_view.stopDrag();
               break;
            case WidgetControllerEvent.VIEW_PINNED:
               _loc2_ = param1.getController();
               _loc3_ = _loc2_.getGlobalListeners();
               if(Boolean(_loc3_) && _loc3_.length > 0)
               {
                  for each(_loc4_ in _loc3_)
                  {
                     addListener(_loc2_,_loc4_,this.onGlobalEvent);
                  }
               }
               break;
            case WidgetControllerEvent.LOAD_CONTENT:
               this.onContentLoaded(param1.getController());
               break;
            case WidgetControllerEvent.ADD_CHILD_VIEW:
               this.onAddChildView(param1.getController());
               break;
            case WidgetControllerEvent.REMOVE_CHILD_VIEW:
               this.onRemoveChildView(param1.getController());
               break;
            case WidgetControllerEvent.MOVE_CHILD_VIEW:
               this.onMoveChildView(param1.getController());
               break;
            case WidgetControllerEvent.LOAD_COMPLETE:
               --this.m_viewsLoading;
               if(this.m_viewsLoading == 0)
               {
                  dispatchEvent(new Event(Event.COMPLETE));
               }
               break;
            default:
               addError("Unknown global event \'" + param1.type + "\' recieved in dialog");
         }
      }
   }
}

