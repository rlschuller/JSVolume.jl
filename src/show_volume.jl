function show_volume(vdata::Array{Float64, 3}; cmap::Matrix{Int64}=[(i==1)*(j-1) + (i==3)*(256-j) for i in 1:3, j in 1:256], default_cmap="viridis", default_renderstyle="iso", clim1=0, clim2=1, isothreshold=0.15)
    HTML{String}(
"""<!DOCTYPE html>
<html lang="en">
<head>
	<title>three.js webgl - volume rendering example</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
	<link type="text/css" rel="stylesheet" href="main.css">
    <style>


body {
    height: 600px;
	margin: 0;
	background-color: #000;
	color: #fff;
	font-family: Monospace;
	font-size: 13px;
	line-height: 24px;
	overscroll-behavior: none;
}
    </style
</head>

<body>

	<div id="inset"></div>

	<script type="module">
        import * as THREE from 'https://cdn.skypack.dev/three@0.133.1';
		import { GUI } from 'https://cdn.skypack.dev/three@0.133.1/examples/jsm/libs/dat.gui.module.js';
		import { OrbitControls } from 'https://cdn.skypack.dev/three@0.133.1/examples/jsm/controls/OrbitControls.js';
		import { NRRDLoader } from 'https://cdn.skypack.dev/three@0.133.1/examples/jsm/loaders/NRRDLoader.js';
		import { VolumeRenderShader1 } from 'https://cdn.skypack.dev/three@0.133.1/examples/jsm/shaders/VolumeShader.js';
		import { WEBGL } from 'https://cdn.skypack.dev/three@0.133.1/examples/jsm/WebGL.js';

		if ( WEBGL.isWebGL2Available() === false ) {

			document.body.appendChild( WEBGL.getWebGL2ErrorMessage() );

		}

		let renderer,
			scene,
			camera,
			controls,
			material,
			volconfig,
			cmtextures;

		init();

		function init() {

			scene = new THREE.Scene();

			// Create renderer
			renderer = new THREE.WebGLRenderer();
			renderer.setPixelRatio( window.devicePixelRatio );
			renderer.setSize( window.innerWidth, window.innerHeight );
			document.body.appendChild( renderer.domElement );

			// Create camera (The volume renderer does not work very well with perspective yet)
			const h = 512; // frustum height
			const aspect = window.innerWidth / window.innerHeight;
			camera = new THREE.OrthographicCamera( - h * aspect / 2, h * aspect / 2, h / 2, - h / 2, 1, 3000 );

            let xLength = """*string(size(vdata)[1])*""";
            let yLength = """*string(size(vdata)[2])*""";
            let zLength = """*string(size(vdata)[3])*""";

            camera.position.set( -1024, yLength / 2 - 0.5, zLength/2.0 - .5 );
			camera.up.set( 0, 0, 1 ); // In our data, z is up


			// Create controls
			controls = new OrbitControls( camera, renderer.domElement );
			controls.addEventListener( 'change', render );
			controls.target.set( xLength / 2 - 0.5, yLength / 2 - 0.5, zLength / 2 - 0.5 );
			controls.minZoom = 0.5;
			controls.maxZoom = 4;
			controls.update();

			//scene.add( new AxesHelper( 128 ) );

			// Lighting is baked into the shader a.t.m.
			// let dirLight = new DirectionalLight( 0xffffff );

			// The gui for interaction
            volconfig = { clim1: """*string(clim1)*""", clim2: """*string(clim2)*""", renderstyle: '"""*default_renderstyle*"""', isothreshold: """*string(isothreshold)*""", colormap: '"""*default_cmap*"""' };

			const gui = new GUI();
			gui.add( volconfig, 'clim1', 0, 1, 0.01 ).onChange( updateUniforms );
			gui.add( volconfig, 'clim2', 0, 1, 0.01 ).onChange( updateUniforms );
			gui.add( volconfig, 'colormap', { gray: 'gray', viridis: 'viridis', custom : 'custom' } ).onChange( updateUniforms );
			gui.add( volconfig, 'renderstyle', { mip: 'mip', iso: 'iso' } ).onChange( updateUniforms );
			gui.add( volconfig, 'isothreshold', 0, 1, 0.01 ).onChange( updateUniforms );

			//// Load the data ...
			//new NRRDLoader().load( "./stent.nrrd", function ( volume ) {

				// Texture to hold the volume. We have scalars, so we put our data in the red channel.
				// THREEJS will select R32F (33326) based on the THREE.RedFormat and THREE.FloatType.
				// Also see https://www.khronos.org/registry/webgl/specs/latest/2.0/#TEXTURE_TYPES_FORMATS_FROM_DOM_ELEMENTS_TABLE
				// TODO: look the dtype up in the volume metadata

                let vdata = new Float32Array("""*string(vdata[:])*""");

				const texture = new THREE.DataTexture3D( vdata, xLength, yLength, zLength );
				//const texture = new THREE.DataTexture3D( volume.data, volume.xLength, volume.yLength, volume.zLength );
                console.log(texture);
				texture.format = THREE.RedFormat;
				texture.type = THREE.FloatType;
				texture.minFilter = texture.magFilter = THREE.LinearFilter;
				texture.unpackAlignment = 1;

                const cm_custom = new Uint8Array("""*string(cmap[:])*""");


                const cm_viridis = new Uint8Array([68, 0, 84, 68, 1, 85, 68, 3, 87, 69, 4, 88, 69, 5, 90, 69, 7, 91, 70, 8, 93, 70, 10, 94, 70, 12, 96, 70, 13, 97, 71, 15, 98, 71, 16, 100, 71, 18, 101, 71, 19, 103, 71, 20, 104, 71, 22, 105, 72, 23, 106, 72, 25, 108, 72, 26, 109, 72, 27, 110, 72, 29, 111, 72, 30, 112, 72, 31, 114, 72, 33, 115, 72, 34, 116, 72, 35, 117, 72, 36, 118, 71, 38, 119, 71, 39, 120, 71, 40, 121, 71, 41, 122, 71, 43, 123, 71, 44, 123, 70, 45, 124, 70, 47, 125, 70, 48, 126, 70, 49, 127, 69, 50, 127, 69, 52, 128, 69, 53, 129, 69, 54, 130, 68, 55, 130, 68, 56, 131, 68, 58, 131, 67, 59, 132, 67, 60, 133, 66, 61, 133, 66, 62, 134, 66, 64, 134, 65, 65, 135, 65, 66, 135, 64, 67, 135, 64, 68, 136, 63, 70, 136, 63, 71, 137, 62, 72, 137, 62, 73, 137, 61, 74, 138, 61, 75, 138, 60, 76, 138, 60, 77, 139, 60, 79, 139, 59, 80, 139, 59, 81, 139, 58, 82, 140, 58, 83, 140, 57, 84, 140, 57, 85, 140, 56, 86, 140, 56, 87, 140, 55, 88, 141, 55, 89, 141, 54, 90, 141, 54, 92, 141, 53, 93, 141, 53, 94, 141, 52, 95, 141, 52, 96, 142, 51, 97, 142, 51, 98, 142, 50, 99, 142, 50, 100, 142, 49, 101, 142, 49, 102, 142, 48, 103, 142, 48, 104, 142, 47, 105, 142, 47, 106, 142, 47, 107, 142, 46, 108, 142, 46, 109, 142, 45, 110, 143, 45, 111, 143, 45, 112, 143, 44, 113, 143, 44, 114, 143, 43, 115, 143, 43, 115, 143, 43, 116, 143, 42, 117, 143, 42, 118, 143, 41, 119, 143, 41, 120, 143, 41, 121, 143, 40, 122, 143, 40, 123, 143, 39, 124, 143, 39, 125, 143, 39, 126, 143, 38, 127, 143, 38, 128, 143, 38, 129, 143, 37, 130, 143, 37, 131, 142, 36, 132, 142, 36, 133, 142, 36, 134, 142, 35, 135, 142, 35, 136, 142, 35, 136, 142, 34, 137, 142, 34, 138, 142, 34, 139, 142, 33, 140, 142, 33, 141, 141, 33, 142, 141, 32, 143, 141, 32, 144, 141, 32, 145, 141, 31, 146, 141, 31, 147, 140, 31, 148, 140, 31, 149, 140, 30, 150, 140, 30, 151, 140, 30, 152, 139, 30, 153, 139, 30, 154, 139, 30, 155, 138, 30, 155, 138, 30, 156, 138, 30, 157, 137, 30, 158, 137, 30, 159, 137, 30, 160, 136, 30, 161, 136, 30, 162, 136, 31, 163, 135, 31, 164, 135, 31, 165, 134, 32, 166, 134, 32, 167, 133, 33, 168, 133, 33, 169, 132, 34, 170, 132, 35, 171, 131, 36, 171, 131, 37, 172, 130, 37, 173, 129, 38, 174, 129, 39, 175, 128, 41, 176, 128, 42, 177, 127, 43, 178, 126, 44, 179, 125, 45, 180, 125, 47, 181, 124, 48, 182, 123, 49, 182, 122, 51, 183, 122, 52, 184, 121, 54, 185, 120, 56, 186, 119, 57, 187, 118, 59, 188, 117, 61, 189, 116, 62, 189, 115, 64, 190, 114, 66, 191, 113, 68, 192, 112, 69, 193, 111, 71, 194, 110, 73, 194, 109, 75, 195, 108, 77, 196, 107, 79, 197, 106, 81, 198, 105, 83, 198, 104, 85, 199, 102, 88, 200, 101, 90, 201, 100, 92, 202, 99, 94, 202, 98, 96, 203, 96, 98, 204, 95, 101, 204, 94, 103, 205, 92, 105, 206, 91, 108, 207, 90, 110, 207, 88, 112, 208, 87, 115, 209, 85, 117, 209, 84, 119, 210, 82, 122, 211, 81, 124, 211, 79, 127, 212, 78, 129, 213, 76, 132, 213, 75, 134, 214, 73, 137, 214, 71, 139, 215, 70, 142, 216, 68, 145, 216, 67, 147, 217, 65, 150, 217, 63, 152, 218, 62, 155, 218, 60, 158, 219, 58, 160, 219, 56, 163, 220, 55, 166, 220, 53, 168, 221, 51, 171, 221, 49, 174, 222, 48, 176, 222, 46, 179, 222, 44, 182, 223, 42, 185, 223, 41, 187, 224, 39, 190, 224, 37, 193, 224, 36, 195, 225, 34, 198, 225, 33, 201, 226, 31, 204, 226, 30, 206, 226, 28, 209, 227, 27, 212, 227, 26, 214, 227, 25, 217, 228, 24, 220, 228, 24, 222, 228, 23, 225, 229, 23, 227, 229, 23, 230, 229, 24, 233, 230, 24, 235, 230, 25, 238, 230, 26, 240, 231, 27, 243, 231, 28, 245, 231, 29, 248, 232, 31, 250, 232, 32, 253, 232, 34, 255, 233, 36]);
                console.log(cm_viridis);

                const cm_gray = new Uint8Array(3 * 256);

                for (let i=0; i< 256; i++) {
                    cm_gray[3*i] = i;
                    cm_gray[3*i+1] = i;
                    cm_gray[3*i+2] = i;
                }

				// Colormap textures
				cmtextures = {
					//viridis: new THREE.TextureLoader().load( 'cm_viridis.png', render ),
					viridis: new THREE.DataTexture(cm_viridis, 256, 1, THREE.RGBFormat  ),
					//gray: new THREE.TextureLoader().load( 'cm_gray.png', render ),
					gray: new THREE.DataTexture(cm_gray, 256, 1, THREE.RGBFormat  ),
					custom: new THREE.DataTexture(cm_custom, 256, 1, THREE.RGBFormat  ),
				};

                console.log(cmtextures);

				// Material
				const shader = VolumeRenderShader1;

				const uniforms = THREE.UniformsUtils.clone( shader.uniforms );

				uniforms[ "u_data" ].value = texture;
				uniforms[ "u_size" ].value.set( xLength, yLength, zLength );
				//uniforms[ "u_size" ].value.set( volume.xLength, volume.yLength, volume.zLength );
				uniforms[ "u_clim" ].value.set( volconfig.clim1, volconfig.clim2 );
				uniforms[ "u_renderstyle" ].value = volconfig.renderstyle == 'mip' ? 0 : 1; // 0: MIP, 1: ISO
				uniforms[ "u_renderthreshold" ].value = volconfig.isothreshold; // For ISO renderstyle
				uniforms[ "u_cmdata" ].value = cmtextures[ volconfig.colormap ];

				material = new THREE.ShaderMaterial( {
					uniforms: uniforms,
					vertexShader: shader.vertexShader,
					fragmentShader: shader.fragmentShader,
					side: THREE.BackSide // The volume shader uses the backface as its "reference point"
				} );

				// THREE.Mesh
				//const geometry = new THREE.BoxGeometry( volume.xLength, volume.yLength, volume.zLength );
				const geometry = new THREE.BoxGeometry( xLength, yLength, zLength );
				//geometry.translate( volume.xLength / 2 - 0.5, volume.yLength / 2 - 0.5, volume.zLength / 2 - 0.5 );
				geometry.translate( xLength / 2 - 0.5, yLength / 2 - 0.5, zLength / 2 - 0.5 );

				const mesh = new THREE.Mesh( geometry, material );
				scene.add( mesh );

				render();

			//} );

			window.addEventListener( 'resize', onWindowResize );

		}

		function updateUniforms() {

			material.uniforms[ "u_clim" ].value.set( volconfig.clim1, volconfig.clim2 );
			material.uniforms[ "u_renderstyle" ].value = volconfig.renderstyle == 'mip' ? 0 : 1; // 0: MIP, 1: ISO
			material.uniforms[ "u_renderthreshold" ].value = volconfig.isothreshold; // For ISO renderstyle
			material.uniforms[ "u_cmdata" ].value = cmtextures[ volconfig.colormap ];

			render();

		}

		function onWindowResize() {

			renderer.setSize( window.innerWidth, window.innerHeight );

			const aspect = window.innerWidth / window.innerHeight;

			const frustumHeight = camera.top - camera.bottom;

			camera.left = - frustumHeight * aspect / 2;
			camera.right = frustumHeight * aspect / 2;

			camera.updateProjectionMatrix();

			render();

		}

		function render() {

			renderer.render( scene, camera );

		}

	</script>

</body>
</html>""")
end

