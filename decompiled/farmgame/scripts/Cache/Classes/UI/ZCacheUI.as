package Cache.Classes.UI
{
   import Cache.Classes.ZCacheUtil;
   import Cache.Interfaces.IZCache;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class ZCacheUI
   {
      
      private var m_stage:Stage;
      
      private var m_sandboxUrl:String;
      
      private var m_drawGradient:Boolean;
      
      private var m_completeCallback:Function;
      
      private var m_offsets:Point;
      
      private var m_sandbox:DisplayObject;
      
      private var m_sandboxLoader:Loader;
      
      private var m_sandboxGradient:Shape = new Shape();
      
      private var m_promptOnSandboxLoad:Boolean = false;
      
      private var m_zCache:IZCache;
      
      public function ZCacheUI(param1:IZCache, param2:Stage, param3:String = null, param4:Boolean = true, param5:Boolean = false)
      {
         super();
         if(!param1)
         {
            throw new Error("ZCachePromptUtil requires a non-null zcache!");
         }
         if(!param2)
         {
            throw new Error("ZCachePromptUtil requires a non-null stage!");
         }
         this.m_zCache = param1;
         this.m_stage = param2;
         this.m_sandboxUrl = param3;
         this.m_drawGradient = param4;
         this.m_offsets = new Point(0,0);
         if(param5)
         {
            this.preloadSandbox();
         }
      }
      
      public function set offsets(param1:Point) : void
      {
         if(param1)
         {
            this.m_offsets = param1;
         }
         else
         {
            this.m_offsets = new Point(0,0);
         }
      }
      
      public function preloadSandbox() : void
      {
         this.loadSandbox();
      }
      
      private function loadSandbox() : void
      {
         if(!this.m_sandboxLoader)
         {
            this.m_sandboxLoader = LoadingManager.load(this.m_sandboxUrl,this.onSandboxLoadSuccess,LoadingManager.PRIORITY_HIGH,this.onSandboxLoadFault);
         }
      }
      
      private function onSandboxLoadSuccess(param1:Event) : void
      {
         this.m_sandbox = this.m_sandboxLoader.content;
         if(this.m_promptOnSandboxLoad)
         {
            this.promptForPermission();
         }
      }
      
      private function onSandboxLoadFault(param1:Event) : void
      {
         if(this.m_promptOnSandboxLoad)
         {
            this.promptForPermission();
         }
      }
      
      public function showPermissionsPrompt(param1:Function = null) : void
      {
         this.m_completeCallback = param1;
         if(this.m_sandbox)
         {
            this.promptForPermission();
         }
         else
         {
            this.m_promptOnSandboxLoad = true;
            this.loadSandbox();
         }
      }
      
      private function promptForPermission() : void
      {
         this.initUI();
         StatsManager.count("zcache","flash_permission","shown");
         this.m_zCache.promptForStorage(ZCacheUtil.applyPartial(this.onFlashPromptDismissed,this,[true]),ZCacheUtil.applyPartial(this.onFlashPromptDismissed,this,[false]));
      }
      
      private function onFlashPromptDismissed(param1:Boolean) : void
      {
         StatsManager.count("zcache","flash_permission",param1 ? "allowed" : "denied");
         StatsManager.count("zcache","status",param1 ? "enabled" : "disabled");
         this.destroy();
         if(this.m_completeCallback !== null)
         {
            this.m_completeCallback(param1);
         }
      }
      
      private function initUI() : void
      {
         if(this.m_drawGradient)
         {
            this.drawSandboxGradient();
            this.m_stage.addChild(this.m_sandboxGradient);
         }
         if(this.m_sandbox)
         {
            this.m_stage.addChild(this.m_sandbox);
            this.m_sandbox.x = (this.m_stage.stageWidth - this.m_sandbox.width >> 1) + this.m_offsets.x;
            this.m_sandbox.y = (this.m_stage.stageHeight - this.m_sandbox.height >> 1) + this.m_offsets.y;
         }
      }
      
      public function destroy() : void
      {
         if(this.m_sandboxGradient)
         {
            if(this.m_sandboxGradient.parent)
            {
               this.m_sandboxGradient.parent.removeChild(this.m_sandboxGradient);
            }
            this.m_sandboxGradient = null;
         }
         if(this.m_sandbox)
         {
            if(this.m_sandbox.parent)
            {
               this.m_sandbox.parent.removeChild(this.m_sandbox);
            }
            this.m_sandbox = null;
         }
         if(this.m_sandboxLoader)
         {
            this.m_sandboxLoader.unload();
            this.m_sandboxLoader = null;
         }
         this.m_zCache = null;
         this.m_stage = null;
      }
      
      private function drawSandboxGradient() : void
      {
         var _loc1_:Number = this.m_stage.stageWidth;
         var _loc2_:Number = this.m_stage.stageHeight;
         var _loc3_:Matrix = new Matrix();
         _loc3_.createGradientBox(_loc1_ * 2,_loc2_ * 2,0,-_loc1_ / 2,-_loc2_ / 2);
         var _loc4_:Graphics = this.m_sandboxGradient.graphics;
         _loc4_.clear();
         _loc4_.beginGradientFill(GradientType.RADIAL,[16777215,3092271],[0,1],[0,255],_loc3_);
         _loc4_.drawRect(0,0,_loc1_,_loc2_);
         _loc4_.endFill();
         this.m_sandboxGradient.width = _loc1_;
         this.m_sandboxGradient.height = _loc2_;
      }
   }
}

