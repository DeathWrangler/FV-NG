package fl.managers
{
   import fl.controls.Button;
   import fl.core.UIComponent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.SimpleButton;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class FocusManager implements IFocusManager
   {
      
      private var focusableObjects:Dictionary;
      
      private var _showFocusIndicator:Boolean = true;
      
      private var defButton:Button;
      
      private var focusableCandidates:Array;
      
      private var _form:DisplayObjectContainer;
      
      private var _defaultButtonEnabled:Boolean = true;
      
      private var activated:Boolean = false;
      
      private var _defaultButton:Button;
      
      private var calculateCandidates:Boolean = true;
      
      private var lastFocus:InteractiveObject;
      
      private var lastAction:String;
      
      public function FocusManager(container:DisplayObjectContainer)
      {
         super();
         focusableObjects = new Dictionary(true);
         if(container != null)
         {
            _form = container;
            addFocusables(DisplayObject(container));
            container.addEventListener(Event.ADDED,addedHandler);
            container.addEventListener(Event.REMOVED,removedHandler);
            activate();
         }
      }
      
      public function get showFocusIndicator() : Boolean
      {
         return _showFocusIndicator;
      }
      
      private function getIndexOfNextObject(i:int, shiftKey:Boolean, bSearchAll:Boolean, groupName:String) : int
      {
         var o:DisplayObject = null;
         var tg1:IFocusManagerGroup = null;
         var j:int = 0;
         var obj:DisplayObject = null;
         var tg2:IFocusManagerGroup = null;
         var n:int = int(focusableCandidates.length);
         var start:int = i;
         while(true)
         {
            if(shiftKey)
            {
               i--;
            }
            else
            {
               i++;
            }
            if(bSearchAll)
            {
               if(shiftKey && i < 0)
               {
                  break;
               }
               if(!shiftKey && i == n)
               {
                  break;
               }
            }
            else
            {
               i = int((i + n) % n);
               if(start == i)
               {
                  break;
               }
            }
            if(isValidFocusCandidate(focusableCandidates[i],groupName))
            {
               o = DisplayObject(findFocusManagerComponent(focusableCandidates[i]));
               if(o is IFocusManagerGroup)
               {
                  tg1 = IFocusManagerGroup(o);
                  for(j = 0; j < focusableCandidates.length; j++)
                  {
                     obj = focusableCandidates[j];
                     if(obj is IFocusManagerGroup)
                     {
                        tg2 = IFocusManagerGroup(obj);
                        if(tg2.groupName == tg1.groupName && tg2.selected)
                        {
                           i = j;
                           break;
                        }
                     }
                  }
               }
               return i;
            }
         }
         return i;
      }
      
      private function mouseFocusChangeHandler(event:FocusEvent) : void
      {
         if(event.relatedObject is TextField)
         {
            return;
         }
         event.preventDefault();
      }
      
      public function set form(value:DisplayObjectContainer) : void
      {
         _form = value;
      }
      
      private function addFocusables(o:DisplayObject, skipTopLevel:Boolean = false) : void
      {
         var focusable:IFocusManagerComponent = null;
         var io:InteractiveObject = null;
         var doc:DisplayObjectContainer = null;
         var i:int = 0;
         var child:DisplayObject = null;
         if(!skipTopLevel)
         {
            if(o is IFocusManagerComponent)
            {
               focusable = IFocusManagerComponent(o);
               if(focusable.focusEnabled)
               {
                  if(focusable.tabEnabled && isTabVisible(o))
                  {
                     focusableObjects[o] = true;
                     calculateCandidates = true;
                  }
                  o.addEventListener(Event.TAB_ENABLED_CHANGE,tabEnabledChangeHandler);
                  o.addEventListener(Event.TAB_INDEX_CHANGE,tabIndexChangeHandler);
               }
            }
            else if(o is InteractiveObject)
            {
               io = o as InteractiveObject;
               if(Boolean(io) && Boolean(io.tabEnabled) && findFocusManagerComponent(io) == io)
               {
                  focusableObjects[io] = true;
                  calculateCandidates = true;
               }
               io.addEventListener(Event.TAB_ENABLED_CHANGE,tabEnabledChangeHandler);
               io.addEventListener(Event.TAB_INDEX_CHANGE,tabIndexChangeHandler);
            }
         }
         if(o is DisplayObjectContainer)
         {
            doc = DisplayObjectContainer(o);
            o.addEventListener(Event.TAB_CHILDREN_CHANGE,tabChildrenChangeHandler);
            if(doc is Stage || doc.parent is Stage || doc.tabChildren)
            {
               for(i = 0; i < doc.numChildren; i++)
               {
                  try
                  {
                     child = doc.getChildAt(i);
                     if(child != null)
                     {
                        addFocusables(doc.getChildAt(i));
                     }
                  }
                  catch(error:SecurityError)
                  {
                  }
               }
            }
         }
      }
      
      private function getChildIndex(parent:DisplayObjectContainer, child:DisplayObject) : int
      {
         return parent.getChildIndex(child);
      }
      
      public function findFocusManagerComponent(component:InteractiveObject) : InteractiveObject
      {
         var p:InteractiveObject = component;
         while(component)
         {
            if(component is IFocusManagerComponent && IFocusManagerComponent(component).focusEnabled)
            {
               return component;
            }
            component = component.parent;
         }
         return p;
      }
      
      private function focusOutHandler(event:FocusEvent) : void
      {
         var target:InteractiveObject = event.target as InteractiveObject;
      }
      
      private function isValidFocusCandidate(o:DisplayObject, groupName:String) : Boolean
      {
         var tg:IFocusManagerGroup = null;
         if(!isEnabledAndVisible(o))
         {
            return false;
         }
         if(o is IFocusManagerGroup)
         {
            tg = IFocusManagerGroup(o);
            if(groupName == tg.groupName)
            {
               return false;
            }
         }
         return true;
      }
      
      private function setFocusToNextObject(event:FocusEvent) : void
      {
         if(!hasFocusableObjects())
         {
            return;
         }
         var o:InteractiveObject = getNextFocusManagerComponent(event.shiftKey);
         if(o)
         {
            setFocus(o);
         }
      }
      
      private function sortFocusableObjectsTabIndex() : void
      {
         var o:Object = null;
         var c:InteractiveObject = null;
         focusableCandidates = [];
         for(o in focusableObjects)
         {
            c = InteractiveObject(o);
            if(Boolean(c.tabIndex) && !isNaN(Number(c.tabIndex)))
            {
               focusableCandidates.push(c);
            }
         }
         focusableCandidates.sort(sortByTabIndex);
      }
      
      private function removeFocusables(o:DisplayObject) : void
      {
         var p:Object = null;
         var dob:DisplayObject = null;
         if(o is DisplayObjectContainer)
         {
            o.removeEventListener(Event.TAB_CHILDREN_CHANGE,tabChildrenChangeHandler);
            o.removeEventListener(Event.TAB_INDEX_CHANGE,tabIndexChangeHandler);
            for(p in focusableObjects)
            {
               dob = DisplayObject(p);
               if(DisplayObjectContainer(o).contains(dob))
               {
                  if(dob == lastFocus)
                  {
                     lastFocus = null;
                  }
                  dob.removeEventListener(Event.TAB_ENABLED_CHANGE,tabEnabledChangeHandler);
                  delete focusableObjects[p];
                  calculateCandidates = true;
               }
            }
         }
      }
      
      private function getTopLevelFocusTarget(o:InteractiveObject) : InteractiveObject
      {
         while(o != InteractiveObject(form))
         {
            if(o is IFocusManagerComponent && IFocusManagerComponent(o).focusEnabled && IFocusManagerComponent(o).mouseFocusEnabled && UIComponent(o).enabled)
            {
               return o;
            }
            o = o.parent;
            if(o == null)
            {
               break;
            }
         }
         return null;
      }
      
      public function sendDefaultButtonEvent() : void
      {
         defButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function addedHandler(event:Event) : void
      {
         var target:DisplayObject = DisplayObject(event.target);
         if(target.stage)
         {
            addFocusables(DisplayObject(event.target));
         }
      }
      
      private function isEnabledAndVisible(o:DisplayObject) : Boolean
      {
         var tf:TextField = null;
         var sb:SimpleButton = null;
         var formParent:DisplayObjectContainer = DisplayObject(form).parent;
         while(o != formParent)
         {
            if(o is UIComponent)
            {
               if(!UIComponent(o).enabled)
               {
                  return false;
               }
            }
            else if(o is TextField)
            {
               tf = TextField(o);
               if(tf.type == TextFieldType.DYNAMIC || !tf.selectable)
               {
                  return false;
               }
            }
            else if(o is SimpleButton)
            {
               sb = SimpleButton(o);
               if(!sb.enabled)
               {
                  return false;
               }
            }
            if(!o.visible)
            {
               return false;
            }
            o = o.parent;
         }
         return true;
      }
      
      private function tabChildrenChangeHandler(event:Event) : void
      {
         if(event.target != event.currentTarget)
         {
            return;
         }
         calculateCandidates = true;
         var o:DisplayObjectContainer = DisplayObjectContainer(event.target);
         if(o.tabChildren)
         {
            addFocusables(o,true);
         }
         else
         {
            removeFocusables(o);
         }
      }
      
      private function deactivateHandler(event:Event) : void
      {
         var target:InteractiveObject = InteractiveObject(event.target);
      }
      
      public function setFocus(component:InteractiveObject) : void
      {
         if(component is IFocusManagerComponent)
         {
            IFocusManagerComponent(component).setFocus();
         }
         else
         {
            form.stage.focus = component;
         }
      }
      
      public function getFocus() : InteractiveObject
      {
         var o:InteractiveObject = form.stage.focus;
         return findFocusManagerComponent(o);
      }
      
      private function hasFocusableObjects() : Boolean
      {
         var o:Object = null;
         var _loc2_:int = 0;
         var _loc3_:* = focusableObjects;
         for(o in _loc3_)
         {
            return true;
         }
         return false;
      }
      
      private function tabIndexChangeHandler(event:Event) : void
      {
         calculateCandidates = true;
      }
      
      public function set defaultButton(value:Button) : void
      {
         var button:Button = value ? Button(value) : null;
         if(button != _defaultButton)
         {
            if(_defaultButton)
            {
               _defaultButton.emphasized = false;
            }
            if(defButton)
            {
               defButton.emphasized = false;
            }
            _defaultButton = button;
            defButton = button;
            if(button)
            {
               button.emphasized = true;
            }
         }
      }
      
      private function sortFocusableObjects() : void
      {
         var o:Object = null;
         var c:InteractiveObject = null;
         focusableCandidates = [];
         for(o in focusableObjects)
         {
            c = InteractiveObject(o);
            if(Boolean(c.tabIndex) && Boolean(!isNaN(Number(c.tabIndex))) && c.tabIndex > 0)
            {
               sortFocusableObjectsTabIndex();
               return;
            }
            focusableCandidates.push(c);
         }
         focusableCandidates.sort(sortByDepth);
      }
      
      private function keyFocusChangeHandler(event:FocusEvent) : void
      {
         showFocusIndicator = true;
         if((event.keyCode == Keyboard.TAB || event.keyCode == 0) && !event.isDefaultPrevented())
         {
            setFocusToNextObject(event);
            event.preventDefault();
         }
      }
      
      private function getIndexOfFocusedObject(o:DisplayObject) : int
      {
         var n:int = int(focusableCandidates.length);
         var i:int = 0;
         for(i = 0; i < n; i++)
         {
            if(focusableCandidates[i] == o)
            {
               return i;
            }
         }
         return -1;
      }
      
      public function hideFocus() : void
      {
      }
      
      private function removedHandler(event:Event) : void
      {
         var i:int = 0;
         var io:InteractiveObject = null;
         var o:DisplayObject = DisplayObject(event.target);
         if(o is IFocusManagerComponent && focusableObjects[o] == true)
         {
            if(o == lastFocus)
            {
               IFocusManagerComponent(lastFocus).drawFocus(false);
               lastFocus = null;
            }
            o.removeEventListener(Event.TAB_ENABLED_CHANGE,tabEnabledChangeHandler);
            delete focusableObjects[o];
            calculateCandidates = true;
         }
         else if(o is InteractiveObject && focusableObjects[o] == true)
         {
            io = o as InteractiveObject;
            if(io)
            {
               if(io == lastFocus)
               {
                  lastFocus = null;
               }
               delete focusableObjects[io];
               calculateCandidates = true;
            }
            o.addEventListener(Event.TAB_ENABLED_CHANGE,tabEnabledChangeHandler);
         }
         removeFocusables(o);
      }
      
      private function sortByDepth(aa:InteractiveObject, bb:InteractiveObject) : Number
      {
         var index:int = 0;
         var tmp:String = null;
         var tmp2:String = null;
         var val1:String = "";
         var val2:String = "";
         var zeros:String = "0000";
         var a:DisplayObject = DisplayObject(aa);
         var b:DisplayObject = DisplayObject(bb);
         while(a != DisplayObject(form) && Boolean(a.parent))
         {
            index = getChildIndex(a.parent,a);
            tmp = index.toString(16);
            if(tmp.length < 4)
            {
               tmp2 = zeros.substring(0,4 - tmp.length) + tmp;
            }
            val1 = tmp2 + val1;
            a = a.parent;
         }
         while(b != DisplayObject(form) && Boolean(b.parent))
         {
            index = getChildIndex(b.parent,b);
            tmp = index.toString(16);
            if(tmp.length < 4)
            {
               tmp2 = zeros.substring(0,4 - tmp.length) + tmp;
            }
            val2 = tmp2 + val2;
            b = b.parent;
         }
         return val1 > val2 ? 1 : (val1 < val2 ? -1 : 0);
      }
      
      public function get defaultButton() : Button
      {
         return _defaultButton;
      }
      
      private function activateHandler(event:Event) : void
      {
         var target:InteractiveObject = InteractiveObject(event.target);
         if(lastFocus)
         {
            if(lastFocus is IFocusManagerComponent)
            {
               IFocusManagerComponent(lastFocus).setFocus();
            }
            else
            {
               form.stage.focus = lastFocus;
            }
         }
         lastAction = "ACTIVATE";
      }
      
      public function showFocus() : void
      {
      }
      
      public function set defaultButtonEnabled(value:Boolean) : void
      {
         _defaultButtonEnabled = value;
      }
      
      public function getNextFocusManagerComponent(backward:Boolean = false) : InteractiveObject
      {
         var tg:IFocusManagerGroup = null;
         if(!hasFocusableObjects())
         {
            return null;
         }
         if(calculateCandidates)
         {
            sortFocusableObjects();
            calculateCandidates = false;
         }
         var o:DisplayObject = form.stage.focus;
         o = DisplayObject(findFocusManagerComponent(InteractiveObject(o)));
         var g:String = "";
         if(o is IFocusManagerGroup)
         {
            tg = IFocusManagerGroup(o);
            g = tg.groupName;
         }
         var i:int = getIndexOfFocusedObject(o);
         var bSearchAll:Boolean = false;
         var start:int = i;
         if(i == -1)
         {
            if(backward)
            {
               i = int(focusableCandidates.length);
            }
            bSearchAll = true;
         }
         var j:int = getIndexOfNextObject(i,backward,bSearchAll,g);
         return findFocusManagerComponent(focusableCandidates[j]);
      }
      
      private function mouseDownHandler(event:MouseEvent) : void
      {
         if(event.isDefaultPrevented())
         {
            return;
         }
         var o:InteractiveObject = getTopLevelFocusTarget(InteractiveObject(event.target));
         if(!o)
         {
            return;
         }
         showFocusIndicator = false;
         if((o != lastFocus || lastAction == "ACTIVATE") && !(o is TextField))
         {
            setFocus(o);
         }
         lastAction = "MOUSEDOWN";
      }
      
      private function isTabVisible(o:DisplayObject) : Boolean
      {
         var p:DisplayObjectContainer = o.parent;
         while(Boolean(p) && Boolean(!(p is Stage)) && !(p.parent && p.parent is Stage))
         {
            if(!p.tabChildren)
            {
               return false;
            }
            p = p.parent;
         }
         return true;
      }
      
      public function get nextTabIndex() : int
      {
         return 0;
      }
      
      private function keyDownHandler(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.TAB)
         {
            lastAction = "KEY";
            if(calculateCandidates)
            {
               sortFocusableObjects();
               calculateCandidates = false;
            }
         }
         if(Boolean(defaultButtonEnabled && event.keyCode == Keyboard.ENTER) && Boolean(defaultButton) && defButton.enabled)
         {
            sendDefaultButtonEvent();
         }
      }
      
      private function focusInHandler(event:FocusEvent) : void
      {
         var x:Button = null;
         var target:InteractiveObject = InteractiveObject(event.target);
         if(form.contains(target))
         {
            lastFocus = findFocusManagerComponent(InteractiveObject(target));
            if(lastFocus is Button)
            {
               x = Button(lastFocus);
               if(defButton)
               {
                  defButton.emphasized = false;
                  defButton = x;
                  x.emphasized = true;
               }
            }
            else if(Boolean(defButton) && defButton != _defaultButton)
            {
               defButton.emphasized = false;
               defButton = _defaultButton;
               _defaultButton.emphasized = true;
            }
         }
      }
      
      private function tabEnabledChangeHandler(event:Event) : void
      {
         calculateCandidates = true;
         var o:InteractiveObject = InteractiveObject(event.target);
         var registeredFocusableObject:Boolean = focusableObjects[o] == true;
         if(o.tabEnabled)
         {
            if(!registeredFocusableObject && isTabVisible(o))
            {
               if(!(o is IFocusManagerComponent))
               {
                  o.focusRect = false;
               }
               focusableObjects[o] = true;
            }
         }
         else if(registeredFocusableObject)
         {
            delete focusableObjects[o];
         }
      }
      
      public function set showFocusIndicator(value:Boolean) : void
      {
         _showFocusIndicator = value;
      }
      
      public function get form() : DisplayObjectContainer
      {
         return _form;
      }
      
      private function sortByTabIndex(a:InteractiveObject, b:InteractiveObject) : int
      {
         return a.tabIndex > b.tabIndex ? 1 : (a.tabIndex < b.tabIndex ? -1 : int(sortByDepth(a,b)));
      }
      
      public function get defaultButtonEnabled() : Boolean
      {
         return _defaultButtonEnabled;
      }
      
      public function activate() : void
      {
         if(activated)
         {
            return;
         }
         form.stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,mouseFocusChangeHandler,false,0,true);
         form.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,keyFocusChangeHandler,false,0,true);
         form.addEventListener(FocusEvent.FOCUS_IN,focusInHandler,true);
         form.addEventListener(FocusEvent.FOCUS_OUT,focusOutHandler,true);
         form.stage.addEventListener(Event.ACTIVATE,activateHandler,false,0,true);
         form.stage.addEventListener(Event.DEACTIVATE,deactivateHandler,false,0,true);
         form.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
         form.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler,true);
         activated = true;
         if(lastFocus)
         {
            setFocus(lastFocus);
         }
      }
      
      public function deactivate() : void
      {
         form.stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,mouseFocusChangeHandler);
         form.stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,keyFocusChangeHandler);
         form.removeEventListener(FocusEvent.FOCUS_IN,focusInHandler,true);
         form.removeEventListener(FocusEvent.FOCUS_OUT,focusOutHandler,true);
         form.stage.removeEventListener(Event.ACTIVATE,activateHandler);
         form.stage.removeEventListener(Event.DEACTIVATE,deactivateHandler);
         form.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
         form.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler,true);
         activated = false;
      }
   }
}

