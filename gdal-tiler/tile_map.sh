#!/bin/bash

default_zoom=16-21

image_name=gdal-tiler
script_name=$(basename -- $0)

main()
{
  parse_args $@

  if [[ $run_natively == true ]]; then
    echo "$script_name: tiling $input_file map to $output_name directory"
    pushd $run_dir > /dev/null
    tile_image
    convert_to_jpeg
    remove_pngs
    cleanup_files
    popd > /dev/null
  else
    check_image
    run_in_docker $@
  fi
}

parse_args()
{
  update_image=false
  run_natively=false
  zoom=$default_zoom

  while getopts "z:unh" opt; do
    case ${opt} in
      z )
        zoom=$OPTARG
        ;;
      u )
        update_image=true
        ;;
      n )
        run_natively=true
        ;;
      h )
        usage
        exit
        ;;
      \? )
        usage
        exit
        ;;
    esac
  done
  shift $((OPTIND -1))

  if [[ -z $1 ]]; then
    echo "$script_name: missing input file"
    usage
    exit 1
  fi
  input_file=$1
  shift

  if [[ -z $1 ]]; then
    echo "$script_name: missing output name"
    usage
    exit 1
  fi
  output_name=$1
  shift
}

check_image()
{
  do_build=$update_image
  if [[ "$(docker images -q $image_name 2> /dev/null)" == "" ]] && [[ $update_image == false ]]; then
    read -p "docker image $image_name not found, do you want to build it [y]? " input
    if [[ ${input^^} == "Y" ]] || [[ ${input^^} == "YES" ]] || [[ ${input} == "" ]]; then
      do_build=true
    fi
  fi
  if [[ $do_build == true ]]; then
    docker build -t $image_name .
  fi
}

run_in_docker()
{
  pushd $run_dir > /dev/null
  docker run \
    -it \
    --rm \
    -u "$(id -u):$(id -g)" \
    -w /images \
    -v $PWD:/images \
    --entrypoint /tile_map.sh \
    gdal-tiler \
    -n $@
  popd > /dev/null
}

tile_image()
{
  gdal2tiles.py --zoom=$zoom -n -w openlayers $input_file $output_name
}

convert_to_jpeg()
{
  find $output_name/ -name '*.png' -exec mogrify -format jpg {} +
}

remove_pngs()
{
  find $output_name/ -name '*.png' -type f -delete
}

cleanup_files()
{
  sed -i "s/png/jpg/g" $output_name/tilemapresource.xml
  sed -i "s/'png'/'jpg'/" $output_name/openlayers.html
}

usage()
{
  bold=$(tput bold)
  normal=$(tput sgr0)

  cat << EOF
Usage:
  $script_name [options] input_file output_name

Options:
  -z zoom   range of zoom levels to create in map tiles
            (default: $default_zoom)

  -u        update docker image

  -n        run natively on host machine, instead of in docker container

EOF
}

run_dir=$PWD
script_dir="$(dirname "$(readlink -f "$0")")"
pushd $script_dir > /dev/null
main $@
popd > /dev/null

