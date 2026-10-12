package Engine.Classes
{
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import com.infomatiq.jsi.RectangleUtil;
   import flash.geom.Rectangle;
   
   public class AOEWorldObject extends WorldObject
   {
      
      protected var m_parentAOEId:int;
      
      protected var m_rect:Rectangle;
      
      public function AOEWorldObject(param1:Rectangle, param2:int, param3:int)
      {
         super();
         setId(param2);
         this.m_parentAOEId = param3;
         this.m_rect = RectangleUtil.clone(param1);
         setSize(param1.width,param1.height,0);
      }
      
      override public function attach() : void
      {
         GlobalEngine.assert(m_outer != null,"Outer for AOEWorldObject is null!");
         if(m_attachPosition == null)
         {
            m_outer.attach(this);
            m_attachPosition = m_position.clone();
            m_attachSize = m_size.clone();
            m_transformDirty = false;
         }
      }
      
      override public function detach() : void
      {
         if(m_attachPosition != null && m_outer != null)
         {
            m_outer.detach(this);
            m_attachPosition = null;
            m_attachSize = null;
            m_displayObjectDirty = true;
            setObjectsDirty();
         }
      }
      
      override public function setPosition(param1:Number, param2:Number, param3:Number = 0) : void
      {
         if(m_position.x != param1 || m_position.y != param2 || m_position.z != param3)
         {
            m_position = new Vector3(param1 + this.m_rect.x,param2 + this.m_rect.y,param3);
            if(m_outer != null)
            {
               m_screenPosition = IsoMath.tilePosToPixelPos(m_position.x,m_position.y,m_position.z,true);
            }
            m_transformDirty = true;
            if(isAttached())
            {
               m_outer.updateObjectInRTree(this);
            }
         }
      }
      
      public function getParentId() : int
      {
         return this.m_parentAOEId;
      }
      
      public function setParentId(param1:int) : void
      {
         this.m_parentAOEId = param1;
      }
   }
}

